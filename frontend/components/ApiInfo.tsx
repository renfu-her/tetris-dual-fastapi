import React, { useEffect, useState } from 'react';

interface ApiInfoData {
  status: string;
  message: string;
  version: string;
  docs: string;
}

interface HealthData {
  status: string;
  service: string;
}

interface ApiInfoProps {
  onClose?: () => void;
}

export const ApiInfo: React.FC<ApiInfoProps> = ({ onClose }) => {
  const [apiInfo, setApiInfo] = useState<ApiInfoData | null>(null);
  const [health, setHealth] = useState<HealthData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const API_BASE_URL = (import.meta as any).env?.VITE_API_BASE_URL || 'http://localhost:8000/api';
  const API_ROOT = API_BASE_URL.replace('/api', '');

  useEffect(() => {
    const fetchApiInfo = async () => {
      setLoading(true);
      setError(null);

      try {
        // Fetch root endpoint
        const rootResponse = await fetch(API_ROOT);
        if (!rootResponse.ok) {
          throw new Error(`Root endpoint failed: ${rootResponse.status}`);
        }
        const rootData = await rootResponse.json();
        setApiInfo(rootData);

        // Fetch health endpoint
        const healthResponse = await fetch(`${API_ROOT}/health`);
        if (!healthResponse.ok) {
          throw new Error(`Health endpoint failed: ${healthResponse.status}`);
        }
        const healthData = await healthResponse.json();
        setHealth(healthData);
      } catch (err) {
        console.error('Failed to fetch API info:', err);
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchApiInfo();
  }, [API_ROOT]);

  return (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <div style={styles.header}>
          <h2 style={styles.title}>🔌 API Information</h2>
          {onClose && (
            <button onClick={onClose} style={styles.closeButton}>
              ✕
            </button>
          )}
        </div>

        <div style={styles.content}>
          {loading && (
            <div style={styles.loading}>
              <p>載入中...</p>
            </div>
          )}

          {error && (
            <div style={styles.error}>
              <h3>❌ 連接失敗</h3>
              <p>{error}</p>
              <p style={styles.errorHint}>
                請確認後端服務是否正在運行：<br />
                <code>cd backend && ./start.sh</code>
              </p>
            </div>
          )}

          {!loading && !error && apiInfo && health && (
            <>
              {/* API Status */}
              <div style={styles.section}>
                <h3 style={styles.sectionTitle}>📡 API 狀態</h3>
                <div style={styles.infoGrid}>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>狀態：</span>
                    <span style={{...styles.value, ...styles.statusOnline}}>
                      ● {apiInfo.status}
                    </span>
                  </div>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>服務：</span>
                    <span style={styles.value}>{apiInfo.message}</span>
                  </div>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>版本：</span>
                    <span style={styles.value}>v{apiInfo.version}</span>
                  </div>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>健康檢查：</span>
                    <span style={{...styles.value, ...styles.statusHealthy}}>
                      ✓ {health.status}
                    </span>
                  </div>
                </div>
              </div>

              {/* Connection Info */}
              <div style={styles.section}>
                <h3 style={styles.sectionTitle}>🌐 連接資訊</h3>
                <div style={styles.infoGrid}>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>API Base URL：</span>
                    <span style={styles.value}>
                      <code style={styles.code}>{API_BASE_URL}</code>
                    </span>
                  </div>
                  <div style={styles.infoItem}>
                    <span style={styles.label}>API Root：</span>
                    <span style={styles.value}>
                      <code style={styles.code}>{API_ROOT}</code>
                    </span>
                  </div>
                </div>
              </div>

              {/* Available Endpoints */}
              <div style={styles.section}>
                <h3 style={styles.sectionTitle}>📋 可用端點</h3>
                <div style={styles.endpoints}>
                  <div style={styles.endpoint}>
                    <span style={styles.method}>GET</span>
                    <code style={styles.code}>{API_ROOT}/</code>
                    <span style={styles.endpointDesc}>API 資訊</span>
                  </div>
                  <div style={styles.endpoint}>
                    <span style={styles.method}>GET</span>
                    <code style={styles.code}>{API_ROOT}/health</code>
                    <span style={styles.endpointDesc}>健康檢查</span>
                  </div>
                  <div style={styles.endpoint}>
                    <span style={styles.methodPost}>POST</span>
                    <code style={styles.code}>{API_BASE_URL}/games</code>
                    <span style={styles.endpointDesc}>儲存遊戲記錄</span>
                  </div>
                  <div style={styles.endpoint}>
                    <span style={styles.method}>GET</span>
                    <code style={styles.code}>{API_BASE_URL}/leaderboard</code>
                    <span style={styles.endpointDesc}>排行榜</span>
                  </div>
                  <div style={styles.endpoint}>
                    <span style={styles.method}>GET</span>
                    <code style={styles.code}>{API_BASE_URL}/leaderboard/stats</code>
                    <span style={styles.endpointDesc}>統計資訊</span>
                  </div>
                </div>
              </div>

              {/* Documentation Links */}
              <div style={styles.section}>
                <h3 style={styles.sectionTitle}>📚 API 文檔</h3>
                <div style={styles.links}>
                  <a
                    href={`${API_ROOT}/docs`}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={styles.link}
                  >
                    📖 Swagger UI
                  </a>
                  <a
                    href={`${API_ROOT}/redoc`}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={styles.link}
                  >
                    📘 ReDoc
                  </a>
                </div>
              </div>

              {/* Environment Info */}
              <div style={styles.section}>
                <h3 style={styles.sectionTitle}>⚙️ 環境設定</h3>
                <div style={styles.envInfo}>
                  <p style={styles.envText}>
                    當前 API URL 從環境變數載入。<br />
                    若需修改，請編輯 <code style={styles.code}>frontend/.env</code> 檔案。
                  </p>
                </div>
              </div>
            </>
          )}
        </div>

        <div style={styles.footer}>
          <button onClick={onClose} style={styles.button}>
            關閉
          </button>
        </div>
      </div>
    </div>
  );
};

// Styles
const styles: { [key: string]: React.CSSProperties } = {
  overlay: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000,
    padding: '20px',
  },
  modal: {
    backgroundColor: '#1a1a2e',
    borderRadius: '12px',
    maxWidth: '800px',
    width: '100%',
    maxHeight: '90vh',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.4)',
  },
  header: {
    padding: '20px 24px',
    borderBottom: '2px solid #16213e',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    margin: 0,
    color: '#00d4ff',
    fontSize: '24px',
    fontWeight: 'bold',
  },
  closeButton: {
    background: 'transparent',
    border: 'none',
    color: '#888',
    fontSize: '24px',
    cursor: 'pointer',
    padding: '0',
    width: '32px',
    height: '32px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '4px',
  },
  content: {
    flex: 1,
    overflow: 'auto',
    padding: '24px',
  },
  loading: {
    textAlign: 'center',
    padding: '40px',
    color: '#aaa',
  },
  error: {
    backgroundColor: '#2d1e1e',
    border: '2px solid #ff4444',
    borderRadius: '8px',
    padding: '20px',
    color: '#ff8888',
  },
  errorHint: {
    marginTop: '12px',
    fontSize: '14px',
    color: '#aaa',
  },
  section: {
    marginBottom: '24px',
    backgroundColor: '#0f1419',
    borderRadius: '8px',
    padding: '16px',
  },
  sectionTitle: {
    margin: '0 0 12px 0',
    color: '#00d4ff',
    fontSize: '18px',
    fontWeight: 'bold',
  },
  infoGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
    gap: '12px',
  },
  infoItem: {
    display: 'flex',
    flexDirection: 'column',
    gap: '4px',
  },
  label: {
    color: '#888',
    fontSize: '14px',
  },
  value: {
    color: '#fff',
    fontSize: '16px',
    fontWeight: '500',
  },
  statusOnline: {
    color: '#4CAF50',
  },
  statusHealthy: {
    color: '#4CAF50',
  },
  code: {
    backgroundColor: '#16213e',
    padding: '2px 6px',
    borderRadius: '4px',
    fontSize: '14px',
    fontFamily: 'monospace',
    color: '#00d4ff',
  },
  endpoints: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },
  endpoint: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '8px',
    backgroundColor: '#16213e',
    borderRadius: '6px',
  },
  method: {
    backgroundColor: '#4CAF50',
    color: '#fff',
    padding: '4px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: 'bold',
    minWidth: '50px',
    textAlign: 'center',
  },
  methodPost: {
    backgroundColor: '#2196F3',
    color: '#fff',
    padding: '4px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: 'bold',
    minWidth: '50px',
    textAlign: 'center',
  },
  endpointDesc: {
    color: '#aaa',
    fontSize: '14px',
  },
  links: {
    display: 'flex',
    gap: '12px',
    flexWrap: 'wrap',
  },
  link: {
    display: 'inline-block',
    padding: '10px 16px',
    backgroundColor: '#16213e',
    color: '#00d4ff',
    textDecoration: 'none',
    borderRadius: '6px',
    fontSize: '14px',
    transition: 'background-color 0.2s',
  },
  envInfo: {
    padding: '12px',
    backgroundColor: '#16213e',
    borderRadius: '6px',
  },
  envText: {
    margin: 0,
    color: '#aaa',
    fontSize: '14px',
    lineHeight: '1.6',
  },
  footer: {
    padding: '16px 24px',
    borderTop: '2px solid #16213e',
    display: 'flex',
    justifyContent: 'flex-end',
  },
  button: {
    padding: '10px 24px',
    backgroundColor: '#00d4ff',
    color: '#0f1419',
    border: 'none',
    borderRadius: '6px',
    fontSize: '16px',
    fontWeight: 'bold',
    cursor: 'pointer',
    transition: 'background-color 0.2s',
  },
};

