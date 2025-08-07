// 应用配置文件 - 使用环境变量管理敏感信息
class AppConfig {
  // Supabase配置 - 从环境变量读取
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aszwrrrcbzrthqfsiwrd.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzendycnJjYnpydGhxZnNpd3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2MzE2ODQsImV4cCI6MjA2NDIwNzY4NH0.C5JbWTmtpfHV9hSUmNB5BH978VxmLDpPJ5yqayU3zws',
  );
  
  // API配置
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.jinbean.com',
  );
  
  // 第三方服务配置
  static const String msgNexusApiKey = String.fromEnvironment(
    'MSG_NEXUS_API_KEY',
    defaultValue: '',
  );
  
  static const String msgNexusBaseUrl = String.fromEnvironment(
    'MSG_NEXUS_BASE_URL',
    defaultValue: 'https://api.msgnexus.com/v1',
  );
  
  // 图片服务配置
  static const String imageServiceUrl = String.fromEnvironment(
    'IMAGE_SERVICE_URL',
    defaultValue: 'https://picsum.photos',
  );
  
  // 开发环境配置
  static const bool isDevelopment = bool.fromEnvironment(
    'IS_DEVELOPMENT',
    defaultValue: true,
  );
  
  static const bool enableDebugLogging = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGGING',
    defaultValue: true,
  );
} 