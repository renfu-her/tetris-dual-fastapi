import React, { useEffect, useState } from 'react';

interface ApiStatusProps {
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
}

export const ApiStatus: React.FC<ApiStatusProps> = ({ position = 'top-right' }) => {
  const [status, setStatus] = useState<'checking' | 'online' | 'offline'>('checking');
  const [apiUrl, setApiUrl] = useState<string>('');
  const [details, setDetails] = useState<{ version?: string; service?: string }>({});

  const API_BASE_URL = (import.meta as any).env?.VITE_API_BASE_URL || 'http://localhost:8000/api';
  const API_ROOT = API_BASE_URL.replace('/api', '');

  useEffect(() => {
    setApiUrl(API_ROOT);
    
    const checkApiStatus = async () => {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout

        const response = await fetch(`${API_ROOT}/`, {
          signal: controller.signal,
        });
        
        clearTimeout(timeoutId);

        if (response.ok) {
          const data = await response.json();
          setStatus('online');
          setDetails({
            version: data.version,
            service: data.message,
          });
        } else {
          setStatus('offline');
        }
      } catch (error) {
        setStatus('offline');
        console.error('API connection failed:', error);
      }
    };

    // Check immediately
    checkApiStatus();

    // Check every 30 seconds
    const interval = setInterval(checkApiStatus, 30000);

    return () => clearInterval(interval);
  }, [API_ROOT]);

  const getPositionStyles = (): React.CSSProperties => {
    const base: React.CSSProperties = {
      position: 'fixed',
      zIndex: 999,
      padding: '8px 12px',
      borderRadius: '8px',
      fontSize: '12px',
      fontFamily: 'monospace',
      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.3)',
      backdropFilter: 'blur(10px)',
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      transition: 'all 0.3s ease',
    };

    switch (position) {
      case 'top-right':
        return { ...base, top: '16px', right: '16px' };
      case 'top-left':
        return { ...base, top: '16px', left: '16px' };
      case 'bottom-right':
        return { ...base, bottom: '16px', right: '16px' };
      case 'bottom-left':
        return { ...base, bottom: '16px', left: '16px' };
      default:
        return { ...base, top: '16px', right: '16px' };
    }
  };

  const getStatusColor = () => {
    switch (status) {
      case 'online':
        return {
          bg: 'rgba(76, 175, 80, 0.2)',
          border: '#4CAF50',
          text: '#4CAF50',
          dot: '#4CAF50',
        };
      case 'offline':
        return {
          bg: 'rgba(244, 67, 54, 0.2)',
          border: '#f44336',
          text: '#f44336',
          dot: '#f44336',
        };
      case 'checking':
        return {
          bg: 'rgba(255, 193, 7, 0.2)',
          border: '#FFC107',
          text: '#FFC107',
          dot: '#FFC107',
        };
    }
  };

  const colors = getStatusColor();

  return (
    <div
      style={{
        ...getPositionStyles(),
        backgroundColor: colors.bg,
        border: `1px solid ${colors.border}`,
        color: colors.text,
      }}
      title={`API: ${apiUrl}`}
    >
      {/* Status Dot with Animation */}
      <div
        style={{
          width: '8px',
          height: '8px',
          borderRadius: '50%',
          backgroundColor: colors.dot,
          animation: status === 'checking' ? 'pulse 1.5s infinite' : 'none',
        }}
      />

      {/* Status Text */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
        <div style={{ fontWeight: 'bold' }}>
          {status === 'online' && '✓ API Online'}
          {status === 'offline' && '✗ API Offline'}
          {status === 'checking' && '⋯ Checking'}
        </div>
        
        {status === 'online' && details.version && (
          <div style={{ fontSize: '10px', opacity: 0.8 }}>
            v{details.version}
          </div>
        )}
        
        {status === 'offline' && (
          <div style={{ fontSize: '10px', opacity: 0.8 }}>
            Connection Failed
          </div>
        )}
      </div>

      {/* CSS Animation */}
      <style>{`
        @keyframes pulse {
          0%, 100% {
            opacity: 1;
            transform: scale(1);
          }
          50% {
            opacity: 0.5;
            transform: scale(1.2);
          }
        }
      `}</style>
    </div>
  );
};

