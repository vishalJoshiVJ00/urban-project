const Complaint = require('../models/Complaint');

// Submit complaint (Updated for 50mb limit)
exports.submitComplaint = async (req, res) => {
  try {
    console.log('📥 Complaint submission request:', req.body);
    console.log('👤 User:', req.user);
    
    let { title, description, imageUrl, audioUrl, videoUrl, location, userId, userName, userContact } = req.body;
    
    // Use authenticated user's ID if not provided
    if (!userId && req.user) {
      userId = req.user.id || req.user._id;
    }
    
    if (!userName && req.user) {
      userName = req.user.name || req.user.firstName || '';
    }
    
    // Auto-convert mobile format
    if (req.body.lat && req.body.long && !location) {
      location = {
        coordinates: [parseFloat(req.body.long), parseFloat(req.body.lat)]
      };
    }
    
    if (req.body.latitude !== undefined && req.body.longitude !== undefined && !location) {
      location = {
        coordinates: [parseFloat(req.body.longitude), parseFloat(req.body.latitude)]
      };
    }
    
    if (!title && description) {
      title = description.substring(0, 50) + (description.length > 50 ? '...' : '');
    }
    
    if (!title || !userId || !location || !location.coordinates || location.coordinates.length !== 2) {
      console.log('❌ Missing required fields:', { 
        title: !!title, 
        userId: !!userId, 
        location: !!location,
        coordinates: location?.coordinates?.length === 2
      });
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: title, userId, and location with coordinates required' 
      });
    }
    
    const [lng, lat] = location.coordinates;
    if (lng < -180 || lng > 180 || lat < -90 || lat > 90) {
      return res.status(400).json({
        success: false,
        error: 'Invalid coordinates: longitude (-180 to 180), latitude (-90 to 90)'
      });
    }
    
    const complaint = new Complaint({
      title,
      description: description || '',
      imageUrl: imageUrl || '',
      audioUrl: audioUrl || '',
      videoUrl: videoUrl || '',
      location: {
        type: 'Point',
        coordinates: location.coordinates
      },
      userId,
      userName: userName || '',
      userContact: userContact || ''
    });
    
    await complaint.save();
    
    // Run AI categorization in background
    setTimeout(() => categorizeComplaint(complaint._id), 100);
    
    console.log('✅ Complaint saved successfully:', complaint._id);
    
    return res.status(201).json({
      success: true,
      message: 'Complaint submitted successfully',
      complaint
    });
  } catch (error) {
    console.error('❌ Submit error:', error.message);
    return res.status(500).json({ 
      success: false, 
      error: 'Something went wrong: ' + error.message 
    });
  }
};

// Get admin complaints (Updated for full user details)
exports.getAdminComplaints = async (req, res) => {
  try {
    // Get complaints based on admin's department
    let filter = { status: { $ne: 'deleted' } };
    if (req.user && req.user.department) {
      filter.assignedDept = req.user.department; // AI routing
    }
    
    const complaints = await Complaint.find(filter)
      .sort({ createdAt: -1 });
    
    const formattedComplaints = complaints.map(comp => ({
      ...comp.toObject(),
      location: {
        type: comp.location.type,
        coordinates: comp.location.coordinates,
        lat: comp.location.coordinates[1],
        lng: comp.location.coordinates[0]
      },
      // Include user details
      user: {
        name: comp.userName,
        email: comp.userId, // This would be user ID, you might need to populate
        contact: comp.userContact
      }
    }));
    
    return res.json({ 
      success: true, 
      plainComplaints: formattedComplaints 
    });
  } catch (error) {
    console.error('Get admin complaints error:', error.message);
    return res.status(500).json({ success: false, error: 'Failed to fetch admin complaints' });
  }
};

// Update status and admin message (New API)
exports.updateStatusAndMessage = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, adminMessage } = req.body;
    
    const validStatuses = ['working', 'solved', 'fake', 'deleted'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Invalid status. Valid: working, solved, fake, deleted' 
      });
    }
    
    // Update complaint with status and admin message
    const updateData = {
      status,
      adminMessage: adminMessage || '',
      adminResponseAt: new Date(),
      updatedAt: new Date()
    };
    
    if (status === 'fake' || status === 'deleted') {
      updateData.status = 'deleted'; // Hide fake complaints
    }
    
    const complaint = await Complaint.findByIdAndUpdate(
      id,
      updateData,
      { new: true }
    );
    
    if (!complaint) {
      return res.status(404).json({ success: false, error: 'Complaint not found' });
    }
    
    return res.json({
      success: true,
      message: 'Status and message updated successfully',
      complaint
    });
  } catch (error) {
    console.error('Update status and message error:', error.message);
    return res.status(500).json({ success: false, error: 'Failed to update status and message' });
  }
};

// Get user's complaints (Updated for status and message)
exports.getMyComplaints = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }
    
    const complaints = await Complaint.find({ userId, status: { $ne: 'deleted' } })
      .sort({ createdAt: -1 });
    
    return res.json({ 
      success: true, 
      complaints: complaints.map(comp => ({
        ...comp.toObject(),
        // Include admin response info
        hasAdminResponse: !!comp.adminMessage,
        adminMessage: comp.adminMessage || 'Problem Submitted',
        adminResponseAt: comp.adminResponseAt
      }))
    });
  } catch (error) {
    console.error('Get my complaints error:', error.message);
    return res.status(500).json({ success: false, error: 'Failed to fetch complaints' });
  }
};

// AI categorization function (Updated for department routing)
async function categorizeComplaint(complaintId) {
  try {
    const complaint = await Complaint.findById(complaintId);
    if (!complaint) return;
    
    const text = (complaint.title + ' ' + (complaint.description || '')).toLowerCase();
    let category = 'other';
    let department = 'general';
    let assignedDept = 'general';
    
    if (text.includes('garbage') || text.includes('waste') || text.includes('kachra') || text.includes('कचरा')) {
      category = 'garbage';
      department = 'sanitation';
      assignedDept = 'garbage';
    } else if (text.includes('water') || text.includes('jal') || text.includes('pipe') || 
               text.includes('paani') || text.includes('पानी') || text.includes('जल')) {
      category = 'water';
      department = 'water-works';
      assignedDept = 'water';
    } else if (text.includes('electricity') || text.includes('bijli') || text.includes('power') || 
               text.includes('light') || text.includes('बिजली')) {
      category = 'electricity';
      department = 'power';
      assignedDept = 'electricity';
    } else if (text.includes('road') || text.includes('sadak') || text.includes('pothole') || 
               text.includes('सड़क')) {
      category = 'road';
      department = 'public-works';
      assignedDept = 'roads';
    } else if (text.includes('health') || text.includes('doctor') || text.includes('hospital') || 
               text.includes('स्वास्थ्य') || text.includes('डॉक्टर')) {
      category = 'health';
      department = 'health';
      assignedDept = 'health';
    }
    
    await Complaint.findByIdAndUpdate(complaintId, {
      category,
      department,
      assignedDept,
      aiProcessed: true
    });
    
    console.log('🤖 AI categorized complaint:', complaintId, '->', category, assignedDept);
  } catch (error) {
    console.error('❌ AI categorization failed:', error.message);
  }
}

// Export other functions as they were...
exports.getComplaints = async (req, res) => {
  try {
    const complaints = await Complaint.find({ status: { $ne: 'deleted' } })
      .sort({ createdAt: -1 });
    return res.json({ 
      success: true, 
      complaints: complaints.map(comp => comp.toObject()) 
    });
  } catch (error) {
    console.error('Get complaints error:', error.message);
    return res.status(500).json({ success: false, error: 'Failed to fetch complaints' });
  }
};

exports.getComplaintById = async (req, res) => {
  try {
    const { id } = req.params;
    const complaint = await Complaint.findById(id);
    
    if (!complaint) {
      return res.status(404).json({ success: false, error: 'Complaint not found' });
    }
    
    return res.json({
      success: true,
      complaint: complaint.toObject()
    });
  } catch (error) {
    console.error('Get complaint by ID error:', error.message);
    return res.status(500).json({ success: false, error: 'Failed to fetch complaint' });
  }
};