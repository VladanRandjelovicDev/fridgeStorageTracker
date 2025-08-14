import express from 'express';
import bodyParser from 'body-parser';
import { v4 as uuidv4 } from 'uuid';
import fs from 'fs-extra';
import path from 'path';

const app = express();
const PORT = 3100;
const DB_FILE = './db.json';

const CATEGORIES = ["fruit", "vegetable", "meat", "dairy", "grain", "other"];

// Middleware
app.use(express.json());

// Helper: Read DB
function readDB() {
    if (!fs.existsSync(DB_FILE)) {
        fs.writeFileSync(DB_FILE, JSON.stringify({ items: [] }, null, 2));
    }
    return JSON.parse(fs.readFileSync(DB_FILE, "utf8"));
}

// Helper: Write DB
function writeDB(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
}

// Fetch all items for a specific user
app.get("/items/:userId", (req, res) => {
    const { userId } = req.params;
    const db = readDB();
    const userItems = db.items.filter(item => item.userId === userId);
    res.json(userItems);
});

// Fetch a single item by ID
app.get("/items/:id", (req, res) => {
    const db = readDB();
    const item = db.items.find(i => i.id === req.params.id);
    if (!item) return res.status(404).json({ error: "Item not found" });
    res.json(item);
});

// Create new item
app.post("/items", (req, res) => {
    const { userId, name, category, bestBefore, dateStored } = req.body;

    if (!userId || !name || !category || !bestBefore || !dateStored) {
        return res.status(400).json({ error: "Missing required fields" });
    }

    if (!CATEGORIES.includes(category)) {
        return res.status(400).json({ error: "Invalid category" });
    }

    const db = readDB();
    const newItem = {
        id: uuidv4(),
        userId,
        name,
        category,
        bestBefore,
        dateStored
    };

    db.items.push(newItem);
    writeDB(db);
    res.status(201).json(newItem);
});

// Update by ID (partial update)
app.put("/items/:id", (req, res) => {
    const db = readDB();
    const itemIndex = db.items.findIndex(i => i.id === req.params.id.toLowerCase());
    if (itemIndex === -1) return res.status(404).json({ error: "Item not found" });

    const updates = req.body;
    if (updates.category && !CATEGORIES.includes(updates.category)) {
        return res.status(400).json({ error: "Invalid category" });
    }

    db.items[itemIndex] = { ...db.items[itemIndex], ...updates };
    writeDB(db);
    res.json(db.items[itemIndex]);
});

// Delete by ID
app.delete("/items/:id", (req, res) => {
    const db = readDB();
    const itemIndex = db.items.findIndex(i => i.id === req.params.id.toLowerCase());
    if (itemIndex === -1) return res.status(404).json({ error: "Item not found" });

    const deletedItem = db.items.splice(itemIndex, 1);
    writeDB(db);
    res.json(deletedItem[0]);
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
