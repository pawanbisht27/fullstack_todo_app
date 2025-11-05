const express = require('express');
const router = express.Router();
const User = require('../models/user');
const jwt = require('jsonwebtoken');

//  SIGNUP + OTP 
router.post('/signup', async (req, res) => {
  try {
    const { fullName, email, password } = req.body;
    if(!fullName || !email || !password) {
      return res.status(400).json({ error: "All fields required" });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if(existingUser) {
      return res.status(400).json({ error: "Email already registered" });
    }

    // Create user
    let user = new User({ fullName, email, password });
    await user.save();

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000);

    // Save OTP + expiry
    user.otp = otp;
    user.otpExpires = new Date(Date.now() + 5*60*1000); // 5 min expiry
    await user.save();

    // ✅ Print OTP in terminal for testing
    console.log("Generated OTP for " + email + ":" + otp);

    res.json({ message: "OTP generated. Check terminal!" });
  } catch (err) {
    console.log(err);
    res.status(400).json({ error: err.message });
  }
});

// ---------------------- VERIFY OTP ----------------------
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;
    if(!email || !otp) {
      return res.status(400).json({ message: "Email and OTP required" });
    }

    const user = await User.findOne({ email });
    if(!user) return res.status(400).json({ message: "User not found" });

    // Check OTP & expiry
    if(user.otp !== Number(otp) || user.otpExpires < new Date()) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    // OTP correct → clear OTP fields + generate JWT
    user.otp = null;
    user.otpExpires = null;
    await user.save();

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ token });
  } catch(err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
});

// ---------------------- LOGIN ----------------------
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if(!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    let user = await User.findOne({ email });
    if(!user) return res.status(400).json({ error: 'Invalid credentials' });

    const isMatch = await user.comparePassword(password);
    if(!isMatch) return res.status(400).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ token });
  } catch(err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;