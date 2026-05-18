// const Book         = require('../models/Book');
// const UserActivity = require('../models/UserActivity');
// const axios        = require('axios');
// const RecommendCache = require('../models/RecommendCache');


// const GEMINI_KEY = process.env.GEMINI_API_KEY;

// // GET /api/recommend
// exports.getRecommendations = async (req, res) => {
//   try {
//     const activities = await UserActivity.find({ userId: req.user.id })
//       .populate('bookId')
//       .sort({ updatedAt: -1 })
//       .limit(20);

//     const allBooks = await Book.find().limit(100);

//     if (allBooks.length === 0)
//       return res.json({
//         recommendations: [],
//         categories: [],
//         recentlyRead: [],
//         similarSections: []
//       });

//     // ── Recently Read ──
//     const recentlyRead = activities
//       .filter(a => a.bookId)
//       .slice(0, 10)
//       .map(a => a.bookId);

//     // ── Similar Sections (Because you read X) ──
//     const similarSections = [];
//     const lastThree = activities.filter(a => a.bookId).slice(0, 3);

//     for (const activity of lastThree) {
//       const sourceBook = activity.bookId;
//       const cats       = sourceBook.categories || [];
//       const authors    = sourceBook.authors    || [];

//       const similar = allBooks.filter(b => {
//         if (b._id.toString() === sourceBook._id.toString()) return false;
//         const alreadyRead = recentlyRead.some(
//           r => r._id.toString() === b._id.toString()
//         );
//         if (alreadyRead) return false;

//         const sharedCat    = b.categories?.some(c => cats.includes(c));
//         const sharedAuthor = b.authors?.some(a => authors.includes(a));
//         return sharedCat || sharedAuthor;
//       }).slice(0, 10);

//       if (similar.length >= 2) {
//         const genre = cats[0] || 'Similar';
//         similarSections.push({
//           sourceBook: {
//             _id:        sourceBook._id,
//             title:      sourceBook.title,
//             coverImage: sourceBook.coverImage
//           },
//           genre,
//           books: similar
//         });
//       }
//     }

// //     // ── Gemini Personalized Recommendations ──
// //     let recommendations = [];
// //     let reason          = '';

// //     const viewedBooks = activities.map(a => ({
// //       title:      a.bookId?.title,
// //       authors:    a.bookId?.authors,
// //       categories: a.bookId?.categories,
// //       timeSpent:  a.timeSpent,
// //     })).filter(b => b.title);

// //     if (viewedBooks.length > 0) {
// //       try {
// //         const readIds  = recentlyRead.map(b => b._id.toString());
// //         const bookList = allBooks
// //           .filter(b => !readIds.includes(b._id.toString()))
// //           .map(b => ({
// //             id:         b._id,
// //             title:      b.title,
// //             authors:    b.authors,
// //             categories: b.categories
// //           }));

// //         const prompt = `
// // You are a book recommendation engine.
// // User's reading activity (timeSpent in seconds = engagement level):
// // ${JSON.stringify(viewedBooks, null, 2)}

// // Available books in database:
// // ${JSON.stringify(bookList, null, 2)}

// // Based on user's interests, pick 5 books from the available list.
// // Return ONLY valid JSON, no markdown, no explanation:
// // {
// //   "personalizedIds": ["id1","id2","id3","id4","id5"],
// //   "reason": "one sentence explaining why these were picked"
// // }
// //         `.trim();

// //         const geminiRes = await axios.post(
// //           `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
// //           {
// //             contents: [{ parts: [{ text: prompt }] }],
// //             generationConfig: { temperature: 0.7, maxOutputTokens: 500 }
// //           }
// //         );

// //         const raw    = geminiRes.data.candidates[0].content.parts[0].text;
// //         const clean  = raw.replace(/```json|```/g, '').trim();
// //         const parsed = JSON.parse(clean);

// //         recommendations = allBooks.filter(b =>
// //           parsed.personalizedIds.includes(b._id.toString())
// //         );
// //         reason = parsed.reason;

// //       } catch (e) {
// //         console.error('Gemini error:', e.message);
// //       }
// //     }

// // ── Gemini Personalized Recommendations ──
// let recommendations = [];
// let reason          = '';

// const viewedBooks = activities.map(a => ({
//   title:      a.bookId?.title,
//   authors:    a.bookId?.authors,
//   categories: a.bookId?.categories,
//   timeSpent:  a.timeSpent,
// })).filter(b => b.title);

// if (viewedBooks.length > 0) {
//   try {
//     const readIds  = recentlyRead.map(b => b._id.toString());
//     const bookList = allBooks
//       .filter(b => !readIds.includes(b._id.toString()))
//       .slice(0, 20) // ← limit to 20 to reduce token usage
//       .map(b => ({
//         id:         b._id,
//         title:      b.title,
//         authors:    b.authors,
//         categories: b.categories
//       }));

//     const prompt = `
// You are a book recommendation engine.
// User read these books (timeSpent in seconds):
// ${JSON.stringify(viewedBooks.slice(0, 5), null, 2)}

// Available books:
// ${JSON.stringify(bookList, null, 2)}

// Pick 5 books the user would enjoy.
// Return ONLY valid JSON, no markdown:
// {
//   "personalizedIds": ["id1","id2","id3","id4","id5"],
//   "reason": "one sentence why"
// }
//     `.trim();

//     // Retry up to 2 times with delay
//     let geminiRes;
//     for (let attempt = 1; attempt <= 2; attempt++) {
//       try {
//         geminiRes = await axios.post(
//           `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
//           {
//             contents: [{ parts: [{ text: prompt }] }],
//             generationConfig: { temperature: 0.7, maxOutputTokens: 300 }
//           }
//         );
//         break; // success, exit loop
//       } catch (e) {
//         if (e.response?.status === 429 && attempt < 2) {
//           console.log('Gemini rate limited, retrying in 3s...');
//           await new Promise(r => setTimeout(r, 3000));
//         } else {
//           throw e;
//         }
//       }
//     }

//     const raw    = geminiRes.data.candidates[0].content.parts[0].text;
//     const clean  = raw.replace(/```json|```/g, '').trim();
//     const parsed = JSON.parse(clean);

//     recommendations = allBooks.filter(b =>
//       parsed.personalizedIds.includes(b._id.toString())
//     );
//     reason = parsed.reason;

//   } catch (e) {
//     console.error('Gemini error:', e.message);
//     // Fallback — recommend by most common category in user history
//     const topCats = viewedBooks
//       .flatMap(b => b.categories || [])
//       .reduce((acc, cat) => {
//         acc[cat] = (acc[cat] || 0) + 1;
//         return acc;
//       }, {});
//     const topCat = Object.entries(topCats).sort((a,b) => b[1]-a[1])[0]?.[0];
//     if (topCat) {
//       recommendations = allBooks
//         .filter(b => b.categories?.includes(topCat))
//         .slice(0, 5);
//       reason = `Based on your interest in ${topCat}`;
//     }
//   }
// }

//     // ── Category Sections ──
//     const usedIds = [
//       ...recentlyRead.map(b => b._id.toString()),
//       ...recommendations.map(b => b._id.toString()),
//       ...similarSections.flatMap(s => s.books.map(b => b._id.toString()))
//     ];
//     const remaining  = allBooks.filter(b => !usedIds.includes(b._id.toString()));
//     const categories = buildDefaultCategories(remaining);

//     res.json({
//       recommendations,
//       reason,
//       recentlyRead,
//       similarSections,
//       categories
//     });

//   } catch (err) {
//     console.error('Recommend error:', err.message);
//     const allBooks = await Book.find().limit(100);
//     res.json({
//       recommendations:  [],
//       categories:       buildDefaultCategories(allBooks),
//       recentlyRead:     [],
//       similarSections:  []
//     });
//   }
// };

// function buildDefaultCategories(books) {
//   const genreKeywords = {
//     'Romance':   ['romance', 'love', 'relationship'],
//     'Comedy':    ['humor', 'comedy', 'funny', 'satire'],
//     'Thriller':  ['thriller', 'mystery', 'suspense', 'crime'],
//     'Fantasy':   ['fantasy', 'magic', 'dragons', 'wizard'],
//     'Science':   ['science', 'physics', 'biology', 'space'],
//     'History':   ['history', 'historical', 'biography'],
//     'Fiction':   ['fiction', 'novel', 'literary'],
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

//   // Fallback — group by first category
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

const Book           = require('../models/Book');
const UserActivity   = require('../models/UserActivity');
const RecommendCache = require('../models/RecommendCache');
const axios          = require('axios');

const GEMINI_KEY = process.env.GEMINI_API_KEY;

exports.getRecommendations = async (req, res) => {
  try {
    const activities = await UserActivity.find({ userId: req.user.id })
      .populate('bookId')
      .sort({ updatedAt: -1 })
      .limit(20);

    const allBooks = await Book.find().limit(100);

    if (allBooks.length === 0)
      return res.json({
        recommendations: [],
        categories:      [],
        recentlyRead:    [],
        similarSections: []
      });

    // ── Recently Read ──
    const recentlyRead = activities
      .filter(a => a.bookId)
      .slice(0, 10)
      .map(a => a.bookId);

    // ── Similar Sections ──
    const similarSections = [];
    const lastThree = activities.filter(a => a.bookId).slice(0, 3);

    for (const activity of lastThree) {
      const sourceBook = activity.bookId;
      const cats       = sourceBook.categories || [];
      const authors    = sourceBook.authors    || [];

      const similar = allBooks.filter(b => {
        if (b._id.toString() === sourceBook._id.toString()) return false;
        const alreadyRead = recentlyRead.some(
          r => r._id.toString() === b._id.toString()
        );
        if (alreadyRead) return false;
        const sharedCat    = b.categories?.some(c => cats.includes(c));
        const sharedAuthor = b.authors?.some(a => authors.includes(a));
        return sharedCat || sharedAuthor;
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

    // ── Gemini Recommendations (with cache) ──
    let recommendations = [];
    let reason          = '';

    const viewedBooks = activities.map(a => ({
      title:      a.bookId?.title,
      authors:    a.bookId?.authors,
      categories: a.bookId?.categories,
      timeSpent:  a.timeSpent,
    })).filter(b => b.title);

    if (viewedBooks.length > 0) {

      // Check cache first — only call Gemini every 30 minutes
      const cache = await RecommendCache.findOne({ userId: req.user.id });
      if (cache && (Date.now() - cache.updatedAt) < 30 * 60 * 1000) {
        console.log('Using cached recommendations');
        recommendations = cache.recommendations;
        reason          = cache.reason;
      } else {
        // Call Gemini
        try {
          const readIds  = recentlyRead.map(b => b._id.toString());
          const bookList = allBooks
            .filter(b => !readIds.includes(b._id.toString()))
            .slice(0, 20)
            .map(b => ({
              id:         b._id,
              title:      b.title,
              authors:    b.authors,
              categories: b.categories
            }));

          const prompt = `
You are a book recommendation engine.
User read these books (timeSpent in seconds):
${JSON.stringify(viewedBooks.slice(0, 5), null, 2)}

Available books:
${JSON.stringify(bookList, null, 2)}

Pick 5 books the user would enjoy.
Return ONLY valid JSON, no markdown:
{
  "personalizedIds": ["id1","id2","id3","id4","id5"],
  "reason": "one sentence why"
}
          `.trim();

          // Retry up to 2 times
          let geminiRes;
          for (let attempt = 1; attempt <= 2; attempt++) {
            try {
              geminiRes = await axios.post(
                `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
                {
                  contents: [{ parts: [{ text: prompt }] }],
                  generationConfig: { temperature: 0.7, maxOutputTokens: 300 }
                }
              );
              break;
            } catch (e) {
              if (e.response?.status === 429 && attempt < 2) {
                console.log('Gemini rate limited, retrying in 3s...');
                await new Promise(r => setTimeout(r, 3000));
              } else {
                throw e;
              }
            }
          }

          const raw    = geminiRes.data.candidates[0].content.parts[0].text;
          const clean  = raw.replace(/```json|```/g, '').trim();
          const parsed = JSON.parse(clean);

          recommendations = allBooks.filter(b =>
            parsed.personalizedIds.includes(b._id.toString())
          );
          reason = parsed.reason;

          // Save to cache
          await RecommendCache.findOneAndUpdate(
            { userId: req.user.id },
            { recommendations, reason, updatedAt: new Date() },
            { upsert: true }
          );

        } catch (e) {
          console.error('Gemini error:', e.message);

          // Fallback — recommend by top category
          const topCats = viewedBooks
            .flatMap(b => b.categories || [])
            .reduce((acc, cat) => {
              acc[cat] = (acc[cat] || 0) + 1;
              return acc;
            }, {});
          const topCat = Object.entries(topCats)
            .sort((a, b) => b[1] - a[1])[0]?.[0];
          if (topCat) {
            recommendations = allBooks
              .filter(b => b.categories?.includes(topCat))
              .slice(0, 5);
            reason = `Based on your interest in ${topCat}`;
          }
        }
      }
    }

    // ── Category Sections ──
    const usedIds = [
      ...recentlyRead.map(b => b._id.toString()),
      ...recommendations.map(b => b._id.toString()),
      ...similarSections.flatMap(s => s.books.map(b => b._id.toString()))
    ];
    const remaining  = allBooks.filter(b => !usedIds.includes(b._id.toString()));
    const categories = buildDefaultCategories(remaining);

    res.json({
      recommendations,
      reason,
      recentlyRead,
      similarSections,
      categories
    });

  } catch (err) {
    console.error('Recommend error:', err.message);
    const allBooks = await Book.find().limit(100);
    res.json({
      recommendations:  [],
      categories:       buildDefaultCategories(allBooks),
      recentlyRead:     [],
      similarSections:  []
    });
  }
};

function buildDefaultCategories(books) {
  const genreKeywords = {
    'Romance':   ['romance', 'love', 'relationship'],
    'Comedy':    ['humor', 'comedy', 'funny', 'satire'],
    'Thriller':  ['thriller', 'mystery', 'suspense', 'crime'],
    'Fantasy':   ['fantasy', 'magic', 'dragons', 'wizard'],
    'Science':   ['science', 'physics', 'biology', 'space'],
    'History':   ['history', 'historical', 'biography'],
    'Fiction':   ['fiction', 'novel', 'literary'],
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