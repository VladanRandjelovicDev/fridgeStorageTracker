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

async function loadData() {
  try {
    const data = await fs.readJson(DB_FILE);
    return data;
  } catch (error) {
    console.error("Error reading DB file:", error);
    return [];
  }
}

async function saveData(data) {
  try {
    await fs.writeJson(DB_FILE, data, { spaces: 2 });
  } catch (error) {
    console.error("Error writing DB file:", error);
  }
}

// DELETE item endpoint
app.delete('/items/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let items = await loadData();

    const initialLength = items.length;
    items = items.filter(item => item.id !== id);

    if (items.length === initialLength) {
      return res.status(404).json({ error: "Item not found" });
    }

    await saveData(items);
    res.status(204).send();
  } catch (error) {
    console.error("Error in DELETE /items/:id:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
