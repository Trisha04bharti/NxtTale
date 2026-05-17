
const Book = require('../models/Book');
const axios = require('axios'); // npm install axios

const GOOGLE_API_KEY = process.env.GOOGLE_BOOKS_API_KEY;

// Save book to MongoDB if not exists, return it
const saveBook = async (item) => {
  const info = item.volumeInfo;
  const existing = await Book.findOne({ googleBookId: item.id });
  if (existing) return existing;

  return await Book.create({
    googleBookId:  item.id,
    title:         info.title || 'Unknown',
    authors:       info.authors || [],
    description:   info.description || '',
    coverImage:    info.imageLinks?.thumbnail?.replace('http://', 'https://') || '',
    publishedDate: info.publishedDate || '',
    pageCount:     info.pageCount || 0,
    categories:    info.categories || [],
    averageRating: info.averageRating || 0,
  });
};

// GET /api/books/feed — home feed (trending/default books)
exports.getFeed = async (req, res) => {
  try {
    // First check if we have books in DB
    const dbBooks = await Book.find().sort({ createdAt: -1 }).limit(20);
    if (dbBooks.length >= 10) return res.json(dbBooks);

    // Fetch from Google Books API
    const response = await axios.get(
      `https://www.googleapis.com/books/v1/volumes?q=bestseller&orderBy=relevance&maxResults=20&key=${GOOGLE_API_KEY}`
    );

    const books = await Promise.all(
      (response.data.items || []).map(saveBook)
    );
    res.json(books);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/books/search?q=harry+potter
exports.searchBooks = async (req, res) => {
  const { q } = req.query;
  if (!q) return res.status(400).json({ message: 'Query required' });

  try {
    const response = await axios.get(
      `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(q)}&maxResults=20&key=${GOOGLE_API_KEY}`
    );

    const books = await Promise.all(
      (response.data.items || []).map(saveBook)
    );
    res.json(books);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};