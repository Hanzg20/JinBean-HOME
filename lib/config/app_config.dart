// 应用配置文件 - 使用环境变量管理敏感信息
class AppConfig {
  // Supabase配置 - 从环境变量读取
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aszwrrrcbzrthqfsiwrd.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
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