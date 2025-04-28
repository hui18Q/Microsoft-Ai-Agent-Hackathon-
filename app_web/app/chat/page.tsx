'use client';
import React, { useState, useRef, useEffect } from 'react';
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
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // 检查token
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/');
    }
  }, [router]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

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
    <div className="flex flex-col h-screen w-full items-center bg-white dark:bg-white-900">
      <div className="flex-1 w-full flex justify-center overflow-hidden">
        <div className="flex flex-col w-full max-w-2xl h-full">
          <div className="flex-1 overflow-y-auto px-4 pt-6 pb-2 custom-scrollbar">
            {messages.length === 0 && <div className="text-gray-400 text-center mt-8">Start your conversation!</div>}
            {messages.map((msg, idx) => (
              <div key={idx} className={`mb-2 flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
                <div className={`px-4 py-2 rounded-lg max-w-[80%] break-words ${msg.role === 'user' ? 'bg-blue-500 text-white' : 'bg-gray-200 dark:bg-gray-700 text-black dark:text-white'}`}>
                  {msg.content}
                </div>
              </div>
            ))}
            <div ref={messagesEndRef} />
          </div>
          {error && <div className="mb-2 text-red-600 px-4">{error}</div>}
        </div>
      </div>
      <form onSubmit={handleSend} className="w-full max-w-2xl flex gap-2 p-4 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 sticky bottom-0">
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
  );
}
