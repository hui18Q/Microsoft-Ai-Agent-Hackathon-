'use client';
import React, { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { UploadOutlined } from '@ant-design/icons';
import type { UploadProps } from 'antd';
import { Button, Upload, message } from 'antd';

interface Message {
  role: 'user' | 'assistant';
  content: string;
  analysis?: any;
}

export default function Chat() {
  const router = useRouter();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
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

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleAnalyzeDocument = async (file: File) => {
    const token = localStorage.getItem('token');
    if (!token) {
      message.error('Please login first');
      router.push('/');
      return false;
    }

    setLoading(true);
    setError('');

    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch('http://localhost:8000/document/analyze', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        body: formData,
      });

      const data = await res.json();
      if (res.ok && data.success) {
        const analysisMessage: Message = {
          role: 'assistant',
          content: 'Document Analysis Result:',
          analysis: data.analysis
        };
        setMessages(msgs => [...msgs, analysisMessage]);
        message.success('Document analysis successful');
        return true;
      } else {
        message.error(data.detail || 'Document analysis failed');
        return false;
      }
    } catch (err) {
      message.error('Network error or server not responding');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const uploadProps: UploadProps = {
    accept: '.pdf',
    showUploadList: false,
    customRequest: async ({ file, onSuccess, onError }) => {
      try {
        await handleAnalyzeDocument(file as File);
        onSuccess?.(null);
      } catch (err) {
        onError?.(err as Error);
      }
    },
    onChange(info) {
      if (info.file.status === 'done') {
        message.success(`${info.file.name} uploaded successfully`);
      } else if (info.file.status === 'error') {
        message.error(`${info.file.name} upload failed`);
      }
    },
  };

  return (
    <div className="flex flex-col h-screen w-full items-center bg-white dark:bg-white-900">
      <div className="flex-1 w-full flex justify-center overflow-hidden">
        <div className="flex flex-col w-full max-w-[80%] h-full">
          <div className="flex-1 overflow-y-auto px-4 pt-6 pb-2 custom-scrollbar">
            {messages.length === 0 && <div className="text-gray-400 text-center mt-8">Start your conversation!</div>}
            {messages.map((msg, idx) => (
              <div key={idx} className={`mb-2 flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
                <div className={`px-4 py-2 rounded-lg max-w-[60%] break-words ${msg.role === 'user' ? 'bg-blue-500 text-white' : 'bg-gray-200 dark:bg-gray-700 text-black dark:text-white'}`}>
                  {msg.content}
                  {msg.analysis && (
                    <div className="mt-2 p-2 bg-white dark:bg-gray-800 rounded border border-gray-200 dark:border-gray-700">
                      <h3 className="font-bold mb-1">Document Type: {msg.analysis.document_type}</h3>
                      <p className="mb-1">From: {msg.analysis.sender}</p>
                      <p className="mb-1">To: {msg.analysis.recipient}</p>
                      <p className="mb-1">Date: {msg.analysis.date}</p>
                      <div className="mt-2">
                        <h4 className="font-bold">Key Information:</h4>
                        <ul className="list-disc pl-5">
                          {msg.analysis.key_items.map((item: string, i: number) => (
                            <li key={i}>{item}</li>
                          ))}
                        </ul>
                      </div>
                      <div className="mt-2">
                        <h4 className="font-bold">Summary:</h4>
                        <p>{msg.analysis.summary}</p>
                      </div>
                      <div className="mt-2">
                        <h4 className="font-bold">Suggested Actions:</h4>
                        <ul className="list-disc pl-5">
                          {msg.analysis.suggested_actions.map((action: string, i: number) => (
                            <li key={i}>{action}</li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            ))}
            <div ref={messagesEndRef} />
          </div>
          {error && <div className="mb-2 text-red-600 px-4">{error}</div>}
        </div>
      </div>
      <div className="w-full flex justify-center bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 sticky bottom-0">
        <div className="w-[80%] p-4">
          <form onSubmit={handleSend} className="flex gap-2">
            <div className="flex-1 relative flex items-center">
              <input
                className="w-full px-3 py-2 pl-10 border border-gray-300 rounded dark:bg-gray-700 dark:text-white"
                value={input}
                onChange={e => setInput(e.target.value)}
                placeholder="Enter your question..."
                disabled={loading}
              />
              <div className="absolute left-2">
                <Upload {...uploadProps}>
                  <Button 
                    type="text"
                    icon={<UploadOutlined />} 
                    className="flex items-center justify-center w-6 h-6 hover:bg-gray-100 dark:hover:bg-gray-600 rounded-full"
                  />
                </Upload>
              </div>
            </div>
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
    </div>
  );
}
