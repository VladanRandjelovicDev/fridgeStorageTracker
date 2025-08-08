const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

let fridgeItems = [
    {
        id: "1",
        name: "Milk",
        dateAdded: new Date(),
        bestBefore: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000) // +3 dana
    }
];

// GET all items
app.get('/items', (req, res) => {
    res.json(fridgeItems);
});

// POST add item
app.post('/items', (req, res) => {
    const { name, bestBefore } = req.body;
    const newItem = {
        id: Date.now().toString(),
        name,
        dateAdded: new Date(),
        bestBefore: new Date(bestBefore)
    };
    fridgeItems.push(newItem);
    res.json(newItem);
});

// DELETE item
app.delete('/items/:id', (req, res) => {
    const { id } = req.params;
    fridgeItems = fridgeItems.filter(item => item.id !== id);
    res.json({ success: true });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Fridge server running on http://localhost:${PORT}`);
});
