# ⭐ GitHub Stars Viewer

A simple, beautiful web application to view and explore anyone's GitHub starred repositories - no login required! (e.g. request to create one, and then go to xyz.com/GeorgePearse Design it so that users don't neeed to login at all, e.g. it should be a pure mirror of github -> all of the discoverability needs to come from good UX, not things like tagging systems.

## ✨ Features

### 🔍 Smart Search & Filtering
- **Real-time search** across repository names, descriptions, and topics
- **Language filtering** to focus on specific technologies
- **Multiple sort options**: Recently starred, Most stars, Name, Recently updated

### 🎯 Automatic Clustering
- **Language-based clusters** - Automatically group stars by programming language
- **Topic-based clusters** - Organize by repository topics and tags
- **Dynamic tabs** showing the most common languages and topics

### 💡 Intelligent Recommendations
- **Personalized suggestions** based on starred repositories
- **Topic analysis** to find similar repos you might like
- **No login required** - works with public GitHub data

### 🎨 Beautiful UI
- Clean, modern design inspired by DeepWiki and Astral
- Centered search interface with recent searches
- Responsive layout for all devices
- Smooth animations and transitions
- Repository cards with languages, topics, and star counts
- localStorage integration to remember your recent searches

## 🚀 Getting Started

### Live Demo
Simply open `index.html` in your browser, or host it on GitHub Pages!

### This fork
This fork is configured for **[@qunewsguy16](https://github.com/qunewsguy16)** - opening the app auto-loads that user's stars. All 763 starred repos were also individually analyzed into a deployment plan — see [DEPLOYMENT.md](DEPLOYMENT.md) (PC / NAS / cloud / Claude Code skills), the full per-repo classification in [deployment/ANALYSIS.md](deployment/ANALYSIS.md), and the remaining human steps in [WIZARD.md](WIZARD.md). To view someone else, use the search box, or link directly with `?user=<name>` / `#<name>` in the URL. Change the `DEFAULT_USERNAME` constant at the top of `script.js` to point the app at a different default account.

### Usage
1. Enter any GitHub username in the search box
2. Click "Load Stars" or press Enter
3. Explore the automatically generated clusters
4. Use search and filters to find specific repositories
5. Discover personalized recommendations

## 🛠️ Technology Stack

- **Pure HTML/CSS/JavaScript** - No frameworks or build tools required
- **GitHub REST API** - For fetching starred repositories
- **Client-side only** - No server or backend needed

## 📊 How It Works

1. **Fetches** all starred repositories for the given username using GitHub's API
2. **Analyzes** the repositories to extract:
   - Programming languages
   - Topics and tags
   - Star counts and update dates
3. **Creates clusters** automatically based on the most common languages and topics
4. **Generates recommendations** by finding popular repositories with similar topics
5. **Displays** everything in an easy-to-navigate interface

## 🌟 Key Differences from Astral

- **No login required** - View anyone's stars, not just your own
- **Automatic organization** - No manual list creation needed
- **Public data only** - Uses GitHub's public API
- **Instant recommendations** - Based solely on starred repos
- **Lightweight** - Simple static files, no complex setup

## 📝 API Rate Limits

GitHub's public API allows 60 requests per hour for unauthenticated requests. For users with many stars (>6000), you may hit rate limits. Consider adding a personal access token to increase the limit to 5000 requests/hour.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

## 📄 License

MIT License - feel free to use this project however you'd like!

## 🙏 Credits & References

- UI Design inspired by [DeepWiki](https://deepwiki.com) - Clean, centered search interface
- Feature inspiration from [Astral](https://astralapp.com) - A great tool for organizing your own GitHub stars
