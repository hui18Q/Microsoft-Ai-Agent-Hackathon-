'use client';
import React, { useState } from 'react';
import { useRouter } from 'next/navigation';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export default function Chat() {
  const router = useRouter();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // 检查token
  React.useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/');
    }
  }, [router]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (!input.trim()) return;
    const token = localStorage.getItem('token');
    if (!token) {
      setError('Please login first');
      router.push('/');
      return;
    }
    const userMsg: Message = { role: 'user', content: input };
    setMessages((msgs) => [...msgs, userMsg]);
    setLoading(true);
    setInput('');
    try {
      const res = await fetch('http://localhost:8000/chat/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({ query: input }),
      });
      const data = await res.json();
      if (res.ok && data.response) {
        setMessages((msgs) => [...msgs, { role: 'assistant', content: data.response }]);
      } else {
        setError(data.detail || 'AI response failed');
      }
    } catch (err) {
      setError('Network error or server not responding');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900 flex flex-col items-center p-4">
      <div className="w-full max-w-2xl bg-white dark:bg-gray-800 rounded shadow p-6 flex flex-col flex-1">
        <h2 className="text-2xl font-bold mb-4">AI Chat</h2>
        <div className="flex-1 overflow-y-auto mb-4 max-h-[60vh]">
          {messages.length === 0 && <div className="text-gray-400">Start your conversation!</div>}
          {messages.map((msg, idx) => (
            <div key={idx} className={`mb-2 flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`px-4 py-2 rounded-lg ${msg.role === 'user' ? 'bg-blue-500 text-white' : 'bg-gray-200 dark:bg-gray-700 text-black dark:text-white'}`}>
                {msg.content}
              </div>
            </div>
          ))}
        </div>
        {error && <div className="mb-2 text-red-600">{error}</div>}
        <form onSubmit={handleSend} className="flex gap-2">
          <input
            className="flex-1 px-3 py-2 border border-gray-300 rounded dark:bg-gray-700 dark:text-white"
            value={input}
            onChange={e => setInput(e.target.value)}
            placeholder="Please enter your question..."
            disabled={loading}
          />
          <button
            type="submit"
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
            disabled={loading}
          >
            {loading ? 'Sending...' : 'Send'}
          </button>
        </form>
      </div>
    </div>
  );
}
