// // const Book         = require('../models/Book');
// // const UserActivity = require('../models/UserActivity');
// // const axios        = require('axios');

// // const GEMINI_KEY   = process.env.GEMINI_API_KEY;
// // const CACHE_TTL_MS = 5 * 60 * 1000; // 5 min cache

// // // Per-user cache: { data, timestamp, lastGeminiCall }
// // const userCache = new Map();

// // exports.getRecommendations = async (req, res) => {
// //   const userId = req.user.id;

// //   // ── Cache Hit — return instantly ──
// //   const cached = userCache.get(userId);
// //   if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
// //     return res.json(cached.data);
// //   }

// //   try {
// //     // ── Parallel DB fetch — no sequential awaits ──
// //     const [activities, allBooks] = await Promise.all([
// //       UserActivity.find({ userId })
// //         .populate('bookId')
// //         .sort({ updatedAt: -1 })          // ← recently viewed first
// //         .limit(20)
// //         .lean(),
// //       Book.find().limit(100).lean()
// //     ]);

// //     if (allBooks.length === 0) {
// //       return res.json({
// //         recommendations: [], reason: '',
// //         categories:      [],
// //         recentlyRead:    [],
// //         similarSections: []
// //       });
// //     }

// //     // ── Recently Read ──
// //     const recentlyRead = activities
// //       .filter(a => a.bookId)
// //       .slice(0, 10)
// //       .map(a => a.bookId);

// //     // ── Similar Sections ──
// //     const similarSections = [];
// //     const lastThree = activities.filter(a => a.bookId).slice(0, 3);

// //     for (const activity of lastThree) {
// //       const sourceBook = activity.bookId;
// //       const cats       = sourceBook.categories || [];
// //       const authors    = sourceBook.authors    || [];

// //       const similar = allBooks.filter(b => {
// //         if (b._id.toString() === sourceBook._id.toString()) return false;
// //         if (recentlyRead.some(r => r._id.toString() === b._id.toString())) return false;
// //         return (
// //           b.categories?.some(c => cats.includes(c)) ||
// //           b.authors?.some(a => authors.includes(a))
// //         );
// //       }).slice(0, 10);

// //       if (similar.length >= 2) {
// //         similarSections.push({
// //           sourceBook: {
// //             _id:        sourceBook._id,
// //             title:      sourceBook.title,
// //             coverImage: sourceBook.coverImage
// //           },
// //           genre: cats[0] || 'Similar',
// //           books: similar
// //         });
// //       }
// //     }

// //     // ── Recommendations ──
// //     let recommendations = [];
// //     let reason          = '';

// //     const viewedBooks = activities
// //       .map(a => ({
// //         title:      a.bookId?.title,
// //         authors:    a.bookId?.authors,
// //         categories: a.bookId?.categories,
// //         timeSpent:  a.timeSpent,
// //       }))
// //       .filter(b => b.title);

// //     if (viewedBooks.length > 0) {
// //       const readIds  = new Set(recentlyRead.map(b => b._id.toString()));
// //       const bookList = allBooks
// //         .filter(b => !readIds.has(b._id.toString()))
// //         .slice(0, 20)
// //         .map(b => ({
// //           id:         b._id,
// //           title:      b.title,
// //           authors:    b.authors,
// //           categories: b.categories
// //         }));

// //       // Only hit Gemini if cache has cooled down
// //       const lastGeminiCall = cached?.lastGeminiCall || 0;
// //       const geminiReady    = Date.now() - lastGeminiCall > CACHE_TTL_MS;

// //       if (geminiReady && bookList.length > 0) {
// //         try {
// //           const prompt = `
// // You are a book recommendation engine.
// // User read these books (timeSpent in seconds = engagement):
// // ${JSON.stringify(viewedBooks.slice(0, 5), null, 2)}

// // Available books:
// // ${JSON.stringify(bookList, null, 2)}

// // Pick 5 books the user would enjoy.
// // Return ONLY valid JSON, no markdown:
// // {
// //   "personalizedIds": ["id1","id2","id3","id4","id5"],
// //   "reason": "one sentence why"
// // }
// //           `.trim();

// //           const geminiRes = await axios.post(
// //             `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
// //             {
// //               contents:         [{ parts: [{ text: prompt }] }],
// //               generationConfig: { temperature: 0.7, maxOutputTokens: 300 }
// //             },
// //             { timeout: 8000 }             // ← don't hang forever
// //           );

// //           const raw    = geminiRes.data.candidates[0].content.parts[0].text;
// //           const clean  = raw.replace(/```json|```/g, '').trim();
// //           const parsed = JSON.parse(clean);

// //           const idSet = new Set(parsed.personalizedIds.map(String));
// //           recommendations = allBooks.filter(b => idSet.has(b._id.toString()));
// //           reason          = parsed.reason;

// //           // Stamp successful Gemini call time
// //           userCache.set(userId, {
// //             ...(userCache.get(userId) || {}),
// //             lastGeminiCall: Date.now()
// //           });

// //           console.log('✅ Gemini recommendations loaded');

// //         } catch (e) {
// //           console.error('Gemini error:', e.message);
// //           ({ recommendations, reason } = fallbackRecommendations(viewedBooks, allBooks));
// //         }

// //       } else {
// //         // Gemini cooling down — reuse last cached picks
// //         recommendations = cached?.data?.recommendations || [];
// //         reason          = cached?.data?.reason          || '';
// //         if (!recommendations.length) {
// //           ({ recommendations, reason } = fallbackRecommendations(viewedBooks, allBooks));
// //         }
// //       }
// //     }

// //     // ── Always guarantee at least 5 recommendations ──
// //     if (recommendations.length === 0) {
// //       recommendations = allBooks
// //         .filter(b => !recentlyRead.some(r => r._id.toString() === b._id.toString()))
// //         .slice(0, 5);
// //       reason = 'Popular books you might enjoy';
// //     }

// //     // ── Category Sections (from unused books only) ──
// //     const usedIds = new Set([
// //       ...recentlyRead.map(b => b._id.toString()),
// //       ...recommendations.map(b => b._id.toString()),
// //       ...similarSections.flatMap(s => s.books.map(b => b._id.toString()))
// //     ]);
// //     const categories = buildDefaultCategories(
// //       allBooks.filter(b => !usedIds.has(b._id.toString()))
// //     );

// //     const responseData = {
// //       recommendations,
// //       reason,
// //       recentlyRead,
// //       similarSections,
// //       categories
// //     };

// //     // ── Store in cache ──
// //     userCache.set(userId, {
// //       data:           responseData,
// //       timestamp:      Date.now(),
// //       lastGeminiCall: userCache.get(userId)?.lastGeminiCall || 0
// //     });

// //     res.json(responseData);

// //   } catch (err) {
// //     console.error('Recommend error:', err.message);
// //     try {
// //       const allBooks = await Book.find().limit(100).lean();
// //       res.json({
// //         recommendations:  [],
// //         reason:           '',
// //         categories:       buildDefaultCategories(allBooks),
// //         recentlyRead:     [],
// //         similarSections:  []
// //       });
// //     } catch (_) {
// //       res.status(500).json({ message: 'Failed to load recommendations' });
// //     }
// //   }
// // };

// // // ── Fallback when Gemini fails ──
// // function fallbackRecommendations(viewedBooks, allBooks) {
// //   const topCats = viewedBooks
// //     .flatMap(b => b.categories || [])
// //     .reduce((acc, cat) => {
// //       acc[cat] = (acc[cat] || 0) + 1;
// //       return acc;
// //     }, {});

// //   const topCat = Object.entries(topCats)
// //     .sort((a, b) => b[1] - a[1])[0]?.[0];

// //   if (topCat) {
// //     return {
// //       recommendations: allBooks.filter(b => b.categories?.includes(topCat)).slice(0, 5),
// //       reason:          `Based on your interest in ${topCat}`
// //     };
// //   }
// //   return {
// //     recommendations: allBooks.slice(0, 5),
// //     reason:          'Popular books you might enjoy'
// //   };
// // }

// // // ── Category sections builder ──
// // function buildDefaultCategories(books) {
// //   const genreKeywords = {
// //     'Romance':  ['romance', 'love', 'relationship'],
// //     'Comedy':   ['humor', 'comedy', 'funny', 'satire'],
// //     'Thriller': ['thriller', 'mystery', 'suspense', 'crime'],
// //     'Fantasy':  ['fantasy', 'magic', 'dragons', 'wizard'],
// //     'Science':  ['science', 'physics', 'biology', 'space'],
// //     'History':  ['history', 'historical', 'biography'],
// //     'Fiction':  ['fiction', 'novel', 'literary'],
// //   };

// //   const sections = {};

// //   Object.entries(genreKeywords).forEach(([genre, keywords]) => {
// //     const matched = books.filter(b => {
// //       const cats  = (b.categories || []).join(' ').toLowerCase();
// //       const title = b.title.toLowerCase();
// //       return keywords.some(k => cats.includes(k) || title.includes(k));
// //     });
// //     if (matched.length >= 2) sections[genre] = matched.slice(0, 10);
// //   });

// //   books.forEach(book => {
// //     const cat = book.categories?.[0];
// //     if (!cat) return;
// //     const key = cat.split('/')[0].trim();
// //     if (!sections[key]) {
// //       const same = books.filter(b => b.categories?.includes(cat));
// //       if (same.length >= 2) sections[key] = same.slice(0, 10);
// //     }
// //   });

// //   return Object.entries(sections).map(([name, books]) => ({ name, books }));
// // }

// const Book         = require('../models/Book');
// const UserActivity = require('../models/UserActivity');
// const axios        = require('axios');

// const GEMINI_KEY   = process.env.GEMINI_API_KEY;
// const CACHE_TTL_MS = 5 * 60 * 1000;

// // Per-user cache
// const userCache = new Map();

// // ── Gemini caller with model fallback ──
// const GEMINI_MODELS = [
//   'gemini-1.5-flash',
//   'gemini-1.0-pro',
// ];

// async function callGemini(prompt) {
//   for (const model of GEMINI_MODELS) {
//     try {
//       const res = await axios.post(
//         `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_KEY}`,
//         {
//           contents:         [{ parts: [{ text: prompt }] }],
//           generationConfig: { temperature: 0.7, maxOutputTokens: 300 }
//         },
//         { timeout: 8000 }
//       );
//       console.log(`✅ Gemini OK using ${model}`);
//       return res.data.candidates[0].content.parts[0].text;
//     } catch (e) {
//       if (e.response?.status === 429) {
//         console.warn(`⚠️  ${model} rate limited, trying next...`);
//         continue;
//       }
//       throw e;
//     }
//   }
//   throw new Error('All Gemini models rate limited');
// }

// // ── Fallback when Gemini fails ──
// function fallbackRecommendations(viewedBooks, allBooks) {
//   const topCats = viewedBooks
//     .flatMap(b => b.categories || [])
//     .reduce((acc, cat) => {
//       acc[cat] = (acc[cat] || 0) + 1;
//       return acc;
//     }, {});

//   const topCat = Object.entries(topCats)
//     .sort((a, b) => b[1] - a[1])[0]?.[0];

//   if (topCat) {
//     return {
//       recommendations: allBooks.filter(b => b.categories?.includes(topCat)).slice(0, 5),
//       reason:          `Based on your interest in ${topCat}`
//     };
//   }
//   return {
//     recommendations: allBooks.slice(0, 5),
//     reason:          'Popular books you might enjoy'
//   };
// }

// // ── Category sections builder ──
// function buildDefaultCategories(books) {
//   const genreKeywords = {
//     'Romance':  ['romance', 'love', 'relationship'],
//     'Comedy':   ['humor', 'comedy', 'funny', 'satire'],
//     'Thriller': ['thriller', 'mystery', 'suspense', 'crime'],
//     'Fantasy':  ['fantasy', 'magic', 'dragons', 'wizard'],
//     'Science':  ['science', 'physics', 'biology', 'space'],
//     'History':  ['history', 'historical', 'biography'],
//     'Fiction':  ['fiction', 'novel', 'literary'],
//   };

//   const sections = {};

//   Object.entries(genreKeywords).forEach(([genre, keywords]) => {
//     const matched = books.filter(b => {
//       const cats  = (b.categories || []).join(' ').toLowerCase();
//       const title = b.title.toLowerCase();
//       return keywords.some(k => cats.includes(k) || title.includes(k));
//     });
//     if (matched.length >= 2) sections[genre] = matched.slice(0, 10);
//   });

//   books.forEach(book => {
//     const cat = book.categories?.[0];
//     if (!cat) return;
//     const key = cat.split('/')[0].trim();
//     if (!sections[key]) {
//       const same = books.filter(b => b.categories?.includes(cat));
//       if (same.length >= 2) sections[key] = same.slice(0, 10);
//     }
//   });

//   return Object.entries(sections).map(([name, books]) => ({ name, books }));
// }

// // ── Main controller ──
// exports.getRecommendations = async (req, res) => {
//   const userId = req.user.id;

//   // ── Cache hit — return instantly ──
//   const cached = userCache.get(userId);
//   if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
//     return res.json(cached.data);
//   }

//   try {
//     // ── Parallel DB fetch ──
//     const [activities, allBooks] = await Promise.all([
//       UserActivity.find({ userId })
//         .populate('bookId')
//         .sort({ updatedAt: -1 })
//         .limit(20)
//         .lean(),
//       Book.find().limit(100).lean()
//     ]);

//     if (allBooks.length === 0) {
//       return res.json({
//         recommendations: [], reason: '',
//         categories:      [],
//         recentlyRead:    [],
//         similarSections: []
//       });
//     }

//     // ── Recently Read ──
//     const recentlyRead = activities
//       .filter(a => a.bookId)
//       .slice(0, 10)
//       .map(a => a.bookId);

//     // ── Similar Sections ──
//     const similarSections = [];
//     const lastThree = activities.filter(a => a.bookId).slice(0, 3);

//     for (const activity of lastThree) {
//       const sourceBook = activity.bookId;
//       const cats       = sourceBook.categories || [];
//       const authors    = sourceBook.authors    || [];

//       const similar = allBooks.filter(b => {
//         if (b._id.toString() === sourceBook._id.toString()) return false;
//         if (recentlyRead.some(r => r._id.toString() === b._id.toString())) return false;
//         return (
//           b.categories?.some(c => cats.includes(c)) ||
//           b.authors?.some(a => authors.includes(a))
//         );
//       }).slice(0, 10);

//       if (similar.length >= 2) {
//         similarSections.push({
//           sourceBook: {
//             _id:        sourceBook._id,
//             title:      sourceBook.title,
//             coverImage: sourceBook.coverImage
//           },
//           genre: cats[0] || 'Similar',
//           books: similar
//         });
//       }
//     }

//     // ── Recommendations ──
//     let recommendations = [];
//     let reason          = '';

//     const viewedBooks = activities
//       .map(a => ({
//         title:      a.bookId?.title,
//         authors:    a.bookId?.authors,
//         categories: a.bookId?.categories,
//         timeSpent:  a.timeSpent,
//       }))
//       .filter(b => b.title);

//     if (viewedBooks.length > 0) {
//       const readIds  = new Set(recentlyRead.map(b => b._id.toString()));
//       const bookList = allBooks
//         .filter(b => !readIds.has(b._id.toString()))
//         .slice(0, 20)
//         .map(b => ({
//           id:         b._id,
//           title:      b.title,
//           authors:    b.authors,
//           categories: b.categories
//         }));

//       // Only call Gemini if cooldown has passed
//       const lastGeminiCall = cached?.lastGeminiCall || 0;
//       const geminiReady    = Date.now() - lastGeminiCall > CACHE_TTL_MS;

//       if (geminiReady && bookList.length > 0) {
//         try {
//           const prompt = `
// You are a book recommendation engine.
// User read these books (timeSpent in seconds = engagement):
// ${JSON.stringify(viewedBooks.slice(0, 5), null, 2)}

// Available books:
// ${JSON.stringify(bookList, null, 2)}

// Pick 5 books the user would enjoy.
// Return ONLY valid JSON, no markdown:
// {
//   "personalizedIds": ["id1","id2","id3","id4","id5"],
//   "reason": "one sentence why"
// }
//           `.trim();

//           const raw    = await callGemini(prompt);
//           const clean  = raw.replace(/```json|```/g, '').trim();
//           const parsed = JSON.parse(clean);

//           const idSet = new Set(parsed.personalizedIds.map(String));
//           recommendations = allBooks.filter(b => idSet.has(b._id.toString()));
//           reason          = parsed.reason;

//           userCache.set(userId, {
//             ...(userCache.get(userId) || {}),
//             lastGeminiCall: Date.now()
//           });

//         } catch (e) {
//           console.error('Gemini error:', e.message);
//           ({ recommendations, reason } = fallbackRecommendations(viewedBooks, allBooks));
//         }

//       } else {
//         // Gemini cooling down — reuse cached picks
//         recommendations = cached?.data?.recommendations || [];
//         reason          = cached?.data?.reason          || '';
//         if (!recommendations.length) {
//           ({ recommendations, reason } = fallbackRecommendations(viewedBooks, allBooks));
//         }
//       }
//     }

//     // ── Always guarantee 5 recommendations ──
//     if (recommendations.length === 0) {
//       recommendations = allBooks
//         .filter(b => !recentlyRead.some(r => r._id.toString() === b._id.toString()))
//         .slice(0, 5);
//       reason = 'Popular books you might enjoy';
//     }

//     // ── Category Sections ──
//     const usedIds = new Set([
//       ...recentlyRead.map(b => b._id.toString()),
//       ...recommendations.map(b => b._id.toString()),
//       ...similarSections.flatMap(s => s.books.map(b => b._id.toString()))
//     ]);
//     const categories = buildDefaultCategories(
//       allBooks.filter(b => !usedIds.has(b._id.toString()))
//     );

//     const responseData = {
//       recommendations,
//       reason,
//       recentlyRead,
//       similarSections,
//       categories
//     };

//     // ── Cache result ──
//     userCache.set(userId, {
//       data:           responseData,
//       timestamp:      Date.now(),
//       lastGeminiCall: userCache.get(userId)?.lastGeminiCall || 0
//     });

//     res.json(responseData);

//   } catch (err) {
//     console.error('Recommend error:', err.message);
//     try {
//       const allBooks = await Book.find().limit(100).lean();
//       res.json({
//         recommendations:  [],
//         reason:           '',
//         categories:       buildDefaultCategories(allBooks),
//         recentlyRead:     [],
//         similarSections:  []
//       });
//     } catch (_) {
//       res.status(500).json({ message: 'Failed to load recommendations' });
//     }
//   }
// };

// const Book         = require('../models/Book');
// const UserActivity = require('../models/UserActivity');
const Book          = require('../models/Book');
const UserActivity  = require('../models/UserActivity');
// const { userCache } = require('./cache'); 

const CACHE_TTL_MS = 30 * 1000 ;
const userCache    = new Map();

// ── Smart recommendation engine (no API needed) ──
function getSmartRecommendations(viewedBooks, allBooks, recentlyReadIds) {
  // Build user interest profile from viewing history
  const categoryScore = {};
  const authorScore   = {};
  const totalTime     = viewedBooks.reduce((sum, b) => sum + (b.timeSpent || 0), 0);

  viewedBooks.forEach(book => {
    // Weight by time spent — more time = stronger interest
    const weight = totalTime > 0 ? (book.timeSpent || 1) / totalTime : 1;

    (book.categories || []).forEach(cat => {
      categoryScore[cat] = (categoryScore[cat] || 0) + weight;
    });
    (book.authors || []).forEach(author => {
      authorScore[author] = (authorScore[author] || 0) + weight;
    });
  });

  // Score every available book
  const scored = allBooks
    .filter(b => !recentlyReadIds.has(b._id.toString()))
    .map(b => {
      let score = 0;

      // Category match
      (b.categories || []).forEach(cat => {
        if (categoryScore[cat]) score += categoryScore[cat] * 3;
      });

      // Author match — strong signal
      (b.authors || []).forEach(author => {
        if (authorScore[author]) score += authorScore[author] * 5;
      });

      return { book: b, score };
    })
    .filter(b => b.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)
    .map(b => b.book);

  // Build reason string
  const topCategory = Object.entries(categoryScore)
    .sort((a, b) => b[1] - a[1])[0]?.[0];
  const topAuthor = Object.entries(authorScore)
    .sort((a, b) => b[1] - a[1])[0]?.[0];

  let reason = '';
  if (topAuthor && authorScore[topAuthor] > 0.3) {
    reason = `Because you enjoy books by ${topAuthor}`;
  } else if (topCategory) {
    reason = `Because you enjoy ${topCategory} books`;
  } else {
    reason = 'Books you might enjoy based on your reading history';
  }

  return { recommendations: scored, reason };
}

// ── Fallback when no history ──
function fallbackRecommendations(allBooks) {
  return {
    recommendations: allBooks.slice(0, 5),
    reason:          'Popular books you might enjoy'
  };
}

// ── Category sections builder ──
function buildDefaultCategories(books) {
  const genreKeywords = {
    'Romance':  ['romance', 'love', 'relationship'],
    'Comedy':   ['humor', 'comedy', 'funny', 'satire'],
    'Thriller': ['thriller', 'mystery', 'suspense', 'crime'],
    'Fantasy':  ['fantasy', 'magic', 'dragons', 'wizard'],
    'Science':  ['science', 'physics', 'biology', 'space'],
    'History':  ['history', 'historical', 'biography'],
    'Fiction':  ['fiction', 'novel', 'literary'],
  };

  const sections = {};

  Object.entries(genreKeywords).forEach(([genre, keywords]) => {
    const matched = books.filter(b => {
      const cats  = (b.categories || []).join(' ').toLowerCase();
      const title = b.title.toLowerCase();
      return keywords.some(k => cats.includes(k) || title.includes(k));
    });
    if (matched.length >= 2) sections[genre] = matched.slice(0, 10);
  });

  books.forEach(book => {
    const cat = book.categories?.[0];
    if (!cat) return;
    const key = cat.split('/')[0].trim();
    if (!sections[key]) {
      const same = books.filter(b => b.categories?.includes(cat));
      if (same.length >= 2) sections[key] = same.slice(0, 10);
    }
  });

  return Object.entries(sections).map(([name, books]) => ({ name, books }));
}

// ── Main controller ──
exports.getRecommendations = async (req, res) => {
  const userId = req.user.id;

  // ── Cache hit — return instantly ──
  const cached = userCache.get(userId);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
    return res.json(cached.data);
  }

  try {
    // ── Parallel DB fetch ──
    const [activities, allBooks] = await Promise.all([
      UserActivity.find({ userId })
        .populate('bookId')
        .sort({ updatedAt: -1 })
        .limit(20)
        .lean(),
      Book.find().limit(100).lean()
    ]);

    if (allBooks.length === 0) {
      return res.json({
        recommendations: [], reason: '',
        categories:      [],
        recentlyRead:    [],
        similarSections: []
      });
    }

    // ── Recently Read ──
    const recentlyRead = activities
      .filter(a => a.bookId)
      .slice(0, 10)
      .map(a => a.bookId);

    const recentlyReadIds = new Set(recentlyRead.map(b => b._id.toString()));

    // ── Similar Sections ──
    const similarSections = [];
    const lastThree = activities.filter(a => a.bookId).slice(0, 3);

    for (const activity of lastThree) {
      const sourceBook = activity.bookId;
      const cats       = sourceBook.categories || [];
      const authors    = sourceBook.authors    || [];

      const similar = allBooks.filter(b => {
        if (b._id.toString() === sourceBook._id.toString()) return false;
        if (recentlyReadIds.has(b._id.toString())) return false;
        return (
          b.categories?.some(c => cats.includes(c)) ||
          b.authors?.some(a => authors.includes(a))
        );
      }).slice(0, 10);

      if (similar.length >= 2) {
        similarSections.push({
          sourceBook: {
            _id:        sourceBook._id,
            title:      sourceBook.title,
            coverImage: sourceBook.coverImage
          },
          genre: cats[0] || 'Similar',
          books: similar
        });
      }
    }

    // ── Smart Recommendations (no API) ──
    let recommendations = [];
    let reason          = '';

    const viewedBooks = activities
      .map(a => ({
        title:      a.bookId?.title,
        authors:    a.bookId?.authors,
        categories: a.bookId?.categories,
        timeSpent:  a.timeSpent,
      }))
      .filter(b => b.title);

    if (viewedBooks.length > 0) {
      ({ recommendations, reason } = getSmartRecommendations(
        viewedBooks,
        allBooks,
        recentlyReadIds
      ));
    }

    // ── Guarantee at least 5 recommendations ──
    if (recommendations.length === 0) {
      ({ recommendations, reason } = fallbackRecommendations(allBooks));
    }

    // ── Category Sections ──
    const usedIds = new Set([
      ...recentlyRead.map(b => b._id.toString()),
      ...recommendations.map(b => b._id.toString()),
      ...similarSections.flatMap(s => s.books.map(b => b._id.toString()))
    ]);
    const categories = buildDefaultCategories(
      allBooks.filter(b => !usedIds.has(b._id.toString()))
    );

    const responseData = {
      recommendations,
      reason,
      recentlyRead,
      similarSections,
      categories
    };

    // ── Cache result ──
    userCache.set(userId, {
      data:      responseData,
      timestamp: Date.now()
    });

    res.json(responseData);

  } catch (err) {
    console.error('Recommend error:', err.message);
    try {
      const allBooks = await Book.find().limit(100).lean();
      res.json({
        recommendations:  [],
        reason:           '',
        categories:       buildDefaultCategories(allBooks),
        recentlyRead:     [],
        similarSections:  []
      });
    } catch (_) {
      res.status(500).json({ message: 'Failed to load recommendations' });
    }
  }
};
// exports.userCache = userCache; 
