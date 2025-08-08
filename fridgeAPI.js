import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { v4 as uuidv4 } from 'uuid';
import fs from 'fs-extra';

const app = express();
const PORT = 3000;
const DB_FILE = './db.json';

app.use(cors());
app.use(bodyParser.json());

// Utility: Load data from file
async function loadData() {
  try {
    const data = await fs.readJson(DB_FILE);
    return data;
  } catch (err) {
    return [];
  }
}

// Utility: Save data to file
async function saveData(data) {
  await fs.writeJson(DB_FILE, data, { spaces: 2 });
}

// GET all items
app.get('/items', async (req, res) => {
  const items = await loadData();
  res.json(items);
});

// POST new item
app.post('/items', async (req, res) => {
  const { name, bestBefore } = req.body;
  if (!name || !bestBefore) {
    return res.status(400).json({ error: "Name and bestBefore are required" });
  }

  const newItem = {
    id: uuidv4(),
    name,
    dateAdded: new Date().toISOString(),
    bestBefore
  };

  const items = await loadData();
  items.push(newItem);
  await saveData(items);

  res.status(201).json(newItem);
});

// DELETE item
app.delete('/items/:id', async (req, res) => {
  const { id } = req.params;
  let items = await loadData();
  const initialLength = items.length;
  items = items.filter(item => item.id !== id);

  if (items.length === initialLength) {
    return res.status(404).json({ error: "Item not found" });
  }

  await saveData(items);
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`✅ Fridge server running on http://localhost:${PORT}`);
});
