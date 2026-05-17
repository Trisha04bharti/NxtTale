
const Book         = require('../models/Book');
const UserActivity = require('../models/UserActivity');
const axios        = require('axios');

const GEMINI_KEY = process.env.GEMINI_API_KEY;

// GET /api/recommend
exports.getRecommendations = async (req, res) => {
  try {
    // 1. Get user activity
    const activities = await UserActivity.find({ userId: req.user.id })
      .populate('bookId')
      .sort({ timeSpent: -1 })
      .limit(15);

    // 2. Build user profile for Gemini
    const viewedBooks = activities.map(a => ({
      title:      a.bookId?.title,
      authors:    a.bookId?.authors,
      categories: a.bookId?.categories,
      timeSpent:  a.timeSpent,
      searchQuery:a.searchQuery
    })).filter(b => b.title);

    // 3. Get all books from DB
    const allBooks = await Book.find().limit(100);

    if (allBooks.length === 0)
      return res.json({ recommendations: [], categories: [] });

    // 4. If no activity yet, return default categories
    if (viewedBooks.length === 0) {
      const categories = buildDefaultCategories(allBooks);
      return res.json({ recommendations: [], categories });
    }

    // 5. Ask Gemini for personalized recommendations
    const bookList = allBooks.map(b => ({
      id:         b._id,
      title:      b.title,
      authors:    b.authors,
      categories: b.categories
    }));

    const prompt = `
You are a book recommendation engine.

User's reading activity (books they viewed, time spent in seconds):
${JSON.stringify(viewedBooks, null, 2)}

Available books in our database:
${JSON.stringify(bookList, null, 2)}

Based on the user's interests shown by their activity, recommend books from the available list.
Return ONLY a valid JSON object (no markdown, no explanation) in this exact format:
{
  "personalizedIds": ["bookId1", "bookId2", "bookId3", "bookId4", "bookId5"],
  "reason": "Brief reason for recommendations"
}
Only include _id values from the available books list.
    `.trim();

    const geminiRes = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_KEY}`,
      {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 500 }
      }
    );

    const raw = geminiRes.data.candidates[0].content.parts[0].text;
    const clean = raw.replace(/```json|```/g, '').trim();
    const parsed = JSON.parse(clean);

    const recommended = allBooks.filter(b =>
      parsed.personalizedIds.includes(b._id.toString())
    );

    // 6. Build category sections from remaining books
    const categories = buildDefaultCategories(
      allBooks.filter(b => !parsed.personalizedIds.includes(b._id.toString()))
    );

    res.json({ recommendations: recommended, categories, reason: parsed.reason });

  } catch (err) {
    console.error('Recommend error:', err.message);
    // Fallback to category-only
    const allBooks = await Book.find().limit(100);
    res.json({ recommendations: [], categories: buildDefaultCategories(allBooks) });
  }
};

function buildDefaultCategories(books) {
  const categoryMap = {};

  books.forEach(book => {
    const cats = book.categories?.length ? book.categories : ['General'];
    cats.forEach(cat => {
      // Normalize category names
      const key = normalizeCat(cat);
      if (!categoryMap[key]) categoryMap[key] = [];
      if (categoryMap[key].length < 10) categoryMap[key].push(book);
    });
  });

  // Add fixed genre buckets
  const genreKeywords = {
    'Romance':  ['romance', 'love', 'relationship'],
    'Comedy':   ['humor', 'comedy', 'funny', 'satire'],
    'Thriller': ['thriller', 'mystery', 'suspense', 'crime'],
    'Fantasy':  ['fantasy', 'magic', 'dragons', 'wizard'],
    'Science':  ['science', 'physics', 'biology', 'space'],
    'History':  ['history', 'historical', 'biography'],
    'Fiction':  ['fiction', 'novel', 'literary'],
  };

  const genreSections = {};
  Object.entries(genreKeywords).forEach(([genre, keywords]) => {
    const matched = books.filter(b => {
      const cats = (b.categories || []).join(' ').toLowerCase();
      const title = b.title.toLowerCase();
      return keywords.some(k => cats.includes(k) || title.includes(k));
    });
    if (matched.length >= 2) genreSections[genre] = matched.slice(0, 10);
  });

  // Merge
  const final = { ...genreSections };
  Object.entries(categoryMap).forEach(([cat, bks]) => {
    if (!final[cat] && bks.length >= 2) final[cat] = bks;
  });

  return Object.entries(final).map(([name, books]) => ({ name, books }));
}

function normalizeCat(cat) {
  return cat.split('/')[0].trim()
    .replace(/&/g, 'and')
    .replace(/\b\w/g, l => l.toUpperCase());
}