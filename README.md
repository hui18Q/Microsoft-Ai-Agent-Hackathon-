# 🧠 CivicAid – AI Copilot for Vulnerable Groups

**An AI-powered multilingual voice assistant to help vulnerable populations access government and social services.**

---

## 🔍 Project Overview

CivicAid is an AI assistant designed for underserved communities. It helps users understand government documents, apply for social benefits, and locate nearby support services. The system supports multilingual voice interaction and simple, guided steps — ideal for people unfamiliar with technology.

### ❓ Problem Statement
- Many vulnerable individuals (elderly, disabled, immigrants, low-income families) struggle to access government or NGO support.
- They may face barriers like:
  - Difficulty reading official letters or understanding forms
  - Limited tech literacy
  - Language and cultural differences
  - Unawareness of available services

### 👥 Target Users
- Elderly individuals
- People with disabilities
- Immigrant and refugee communities
- Low-income families
- Social workers, NGOs, caregivers

---

## 🌟 Key Features

| Feature                        | Description                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| 🗣️ Natural Language Q&A Copilot  | Ask questions like “How to apply for housing aid?” via voice or text        |
| 🌍 Multilingual Support        | Real-time translation via Azure Translator for better accessibility         |
| 📄 Document Understanding      | Users upload official letters → AI summarizes in simple terms (GPT-4 Vision)|
| 🧾 Smart Form Assistant        | AI fills in application forms step-by-step based on user’s answers          |
| 📍 Service Finder              | Locate nearby public/private support services using Bing/Azure Maps         |
| 🧠 Case Memory (Optional)      | With consent, AI remembers previous needs, forms, and suggestions           |

---

## 🧠 AI Agent Role

- Functions as a **conversational assistant** powered by GPT-4 (via Azure OpenAI)
- Uses **Semantic Kernel** or **LangChain** for prompt orchestration and memory
- Understands uploaded documents using **GPT-4 Vision** or **Azure Form Recognizer**
- Provides multilingual voice interaction using **Azure Speech Services**
- Translates in real time using **Azure Translator**
- Retrieves location-based service info via **Azure or Bing Maps API**

---

## ⚙️ Tech Stack

- 🧠 Azure OpenAI (GPT-4)
- 🧩 Semantic Kernel or LangChain
- 🗣 Azure Speech Services
- 🌐 Azure Translator
- 📄 GPT-4 Vision / Azure Form Recognizer
- 🗺 Azure Maps / Bing Maps API
- 🧰 Flutter (mobile frontend)
- 🐍 Python (backend via Azure Functions)
- ☁️ Cosmos DB (optional for memory/logs)

---

## 🔄 User Workflow

1. User (or helper) opens the app
2. User speaks or types a question (e.g., “Where can I get rental help?”)
3. AI answers clearly with personalized steps
4. User uploads a government letter → AI reads and explains it
5. AI helps fill out required forms with guided Q&A
6. AI shows nearby support centers using a map
7. (Optional) AI saves progress and remembers user’s needs for next time

---

## 📈 Future Improvements

- Human-in-the-loop: Connect to live social workers if needed
- Offline version for low-connectivity areas
- WhatsApp / LINE integration for accessibility
- NGO-side admin portal to register services
- Analytics dashboard to help government track unmet needs

---

## 🤝 Real-World Usage Scenarios

CareBridge AI is designed not only for individual users, but also for:

- Family members helping elderly parents
- Community volunteers or caregivers
- NGOs offering field services
- Government offices or local centers using shared kiosks or tablets

Even if users **cannot read, write, or operate a phone**, the app can be **voice-operated** with support from a caregiver or social worker.

---

## 📷 Demo

(https://drive.google.com/file/d/1z0qlhH9d8E-jLnRLvnym3mwTtRLQop7Y/view?usp=sharing)

---

## 📄 License

MIT License

---

> Built for the [Microsoft AI Agents Hackathon](https://microsoft.github.io/AI_Agents_Hackathon/)

