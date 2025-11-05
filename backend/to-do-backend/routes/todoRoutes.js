const express = require('express');
const router = express.Router();
const Todo = require('../models/Todo');
const jwt = require('jsonwebtoken');

// Middleware to verify JWT
const auth = (req, res, next) => {
  const token = req.headers['authorization'];
  if(!token) return res.status(401).json({ error: 'Unauthorized' });
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if(err) return res.status(401).json({ error: 'Unauthorized' });
    req.userId = decoded.id;
    next();
  });
};

// GET all todos
router.get('/all', auth, async (req, res) => {
  const todos = await Todo.find({ userId: req.userId });
  res.json(todos);
});

// ADD todo
router.post('/add', auth, async (req, res) => {
  const todo = new Todo({ ...req.body, userId: req.userId });
  await todo.save();
  res.status(201).json(todo);
});

// UPDATE todo (edit title)
router.put('/update/:id', auth, async (req, res) => {
  try {
    const todo = await Todo.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { title: req.body.title }, // edit title
      { new: true }
    );
    if(!todo) return res.status(404).json({ error: 'Todo not found' });
    res.json(todo);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update todo' });
  }
});

// TOGGLE completed
router.put('/toggle/:id', auth, async (req, res) => {
  try {
    const todo = await Todo.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { completed: req.body.completed },
      { new: true }
    );
    res.json(todo);
  } catch (err) {
    res.status(500).json({ error: 'Failed to toggle todo' });
  }
});

// DELETE todo
router.delete('/delete/:id', auth, async (req, res) => {
  await Todo.findOneAndDelete({ _id: req.params.id, userId: req.userId });
  res.json({ message: 'Deleted' });
});

module.exports = router;