// 服务架构导出文件
// 统一导出所有服务相关的类和接口

// 服务接口
export 'interfaces/i_authentication_service.dart';
export 'interfaces/i_service_query_service.dart';
export 'interfaces/i_service_detail_service.dart';
export 'interfaces/i_provider_service.dart';

// 服务管理器
export 'service_manager.dart';

// 动态Tab配置服务
export 'dynamic_tab_config_service.dart';

// 数据模型 - 现在使用Domain实体
export '../../features/customer/domain/entities/service.dart';
export '../../features/customer/domain/entities/service_detail.dart';
