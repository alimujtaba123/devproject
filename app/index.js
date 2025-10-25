const express = require('express');
const app = express();
app.use(express.json());
let notes = [];
app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.get('/notes', (req, res) => res.json(notes));
app.post('/notes', (req, res) => {
const { title, text } = req.body;
const id = Date.now().toString();
const note = { id, title, text };
notes.push(note);
res.status(201).json(note);
});
app.delete('/notes/:id', (req, res) => {
notes = notes.filter(n => n.id !== req.params.id);
res.status(204).send();
});
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`CloudNotes backend running succesfully on port 3000! ${port}`));