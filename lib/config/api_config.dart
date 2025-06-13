// 📁 config/api_config.dart
class ApiConfig {
  // API Configuration
  static const String exchangeRateApiKey = '2fc68d6143d20fb4dc5d6a7c'; // Exchange Rate API
  static const String metalsApiKey = 'YOUR_METALS_API_KEY'; // Get from metals-api.com
  static const String alphaVantageApiKey = 'YOUR_ALPHA_VANTAGE_KEY'; // Get from alphavantage.co
  
  // API Base URLs
  static const String exchangeRateApiBase = 'https://v6.exchangerate-api.com/v6';
  static const String exchangeRateHostBase = 'https://api.exchangerate.host/latest';
  static const String metalsLiveBase = 'https://api.metals.live/v1/spot';
    // API Endpoints
  static String getExchangeRateApiUrl({required String baseCurrency}) {
    return '$exchangeRateApiBase/$exchangeRateApiKey/latest/$baseCurrency';
  }
  
  static String getExchangeRateHostUrl({required String base, required String symbols}) {
    return '$exchangeRateHostBase?base=$base&symbols=$symbols';
  }
  
  static String getMetalsApiUrl({required String metals, required String currency}) {
    return 'https://api.metals.live/v1/spot/$metals?currency=$currency';
  }
  
  // Alternative APIs for production use
  static String getAlphaVantageUrl(String symbol) {
    return 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$alphaVantageApiKey';
  }
}

// API Response Models
class MetalPrice {
  final String symbol;
  final String name;
  final double price;
  final String currency;
  final DateTime timestamp;
  
  MetalPrice({
    required this.symbol,
    required this.name,
    required this.price,
    required this.currency,
    required this.timestamp,
  });
  
  factory MetalPrice.fromJson(Map<String, dynamic> json) {
    return MetalPrice(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

// API Service Class
class MetalPriceService {
  static Future<Map<String, double>> fetchPricesFromExchangeRate() async {
    // This is implemented in the page files
    throw UnimplementedError('Use the implementation in page files');
  }
  
  // For future implementation with paid APIs
  static Future<Map<String, double>> fetchPricesFromMetalsApi() async {
    // Implement when you have a paid API key
    throw UnimplementedError('Requires API key from metals-api.com');
  }
}
