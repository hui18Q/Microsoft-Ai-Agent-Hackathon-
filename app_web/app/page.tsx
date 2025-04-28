'use client';
import React, { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [verificationCode, setVerificationCode] = useState('');
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');

  const handleSendVerificationCode = async () => {
    try {
      const response = await fetch('http://localhost:8000/users/send-verification-code', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });
      const data = await response.json();
      if (response.ok) {
        setMessage('验证码已发送到您的邮箱');
      } else {
        setError(data.detail);
      }
    } catch (err) {
      setError('发送验证码失败，请稍后重试');
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await fetch('http://localhost:8000/users/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          username,
          password,
          verification_code: verificationCode,
        }),
      });
      const data = await response.json();
      if (response.ok) {
        setMessage('注册成功，请登录');
        setIsLogin(true);
      } else {
        setError(data.detail);
      }
    } catch (err) {
      setError('注册失败，请稍后重试');
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await fetch('http://localhost:8000/users/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          password,
        }),
      });
      const data = await response.json();
      if (response.ok) {
        localStorage.setItem('token', data.access_token);
        router.push('/chat');
      } else {
        setError(data.detail);
      }
    } catch (err) {
      setError('登录失败，请稍后重试');
    }
  };

  return (
    <div className="grid grid-rows-[1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-[32px] row-start-1 items-center sm:items-start">
        <div className="w-full max-w-md p-8 space-y-8 bg-white rounded-lg shadow-md dark:bg-gray-800">
          <div className="text-center">
            <h2 className="text-3xl font-bold">{isLogin ? '登录' : '注册'}</h2>
          </div>

          {error && (
            <div className="p-4 text-red-700 bg-red-100 rounded-md">
              {error}
            </div>
          )}

          {message && (
            <div className="p-4 text-green-700 bg-green-100 rounded-md">
              {message}
            </div>
          )}

          <form className="mt-8 space-y-6" onSubmit={isLogin ? handleLogin : handleRegister}>
            <div className="space-y-4">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  邮箱
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  required
                  className="w-full px-3 py-2 mt-1 border border-gray-300 rounded-md dark:border-gray-600 dark:bg-gray-700"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              {!isLogin && (
                <>
                  <div>
                    <label htmlFor="username" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      用户名
                    </label>
                    <input
                      id="username"
                      name="username"
                      type="text"
                      required
                      className="w-full px-3 py-2 mt-1 border border-gray-300 rounded-md dark:border-gray-600 dark:bg-gray-700"
                      value={username}
                      onChange={(e) => setUsername(e.target.value)}
                    />
                  </div>

                  <div>
                    <label htmlFor="verificationCode" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      验证码
                    </label>
                    <div className="flex gap-2">
                      <input
                        id="verificationCode"
                        name="verificationCode"
                        type="text"
                        required
                        className="flex-1 px-3 py-2 mt-1 border border-gray-300 rounded-md dark:border-gray-600 dark:bg-gray-700"
                        value={verificationCode}
                        onChange={(e) => setVerificationCode(e.target.value)}
                      />
                      <button
                        type="button"
                        onClick={handleSendVerificationCode}
                        className="px-4 py-2 mt-1 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
                      >
                        发送验证码
                      </button>
                    </div>
                  </div>
                </>
              )}

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  密码
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  className="w-full px-3 py-2 mt-1 border border-gray-300 rounded-md dark:border-gray-600 dark:bg-gray-700"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
            </div>

            <div>
              <button
                type="submit"
                className="w-full px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
              >
                {isLogin ? '登录' : '注册'}
              </button>
            </div>

            <div className="text-center">
              <button
                type="button"
                onClick={() => {
                  setIsLogin(!isLogin);
                  setError('');
                  setMessage('');
                }}
                className="text-sm text-blue-600 hover:text-blue-500"
              >
                {isLogin ? '没有账号？立即注册' : '已有账号？立即登录'}
              </button>
            </div>
          </form>
        </div>
      </main>
    </div>
  );
}
