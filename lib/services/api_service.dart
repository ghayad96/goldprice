import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Fetch exchange rates using your Exchange Rate API key
  static Future<Map<String, dynamic>?> getExchangeRates({
    required String baseCurrency,
  }) async {
    try {
      final url = ApiConfig.getExchangeRateApiUrl(baseCurrency: baseCurrency);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          return data;
        } else {
          print('API Error: ${data['error-type']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }
  
  // Fetch multiple exchange rates for price comparison
  static Future<Map<String, double>?> getMultiCurrencyRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  }) async {
    try {
      final data = await getExchangeRates(baseCurrency: baseCurrency);
      if (data != null && data['conversion_rates'] != null) {
        final rates = data['conversion_rates'] as Map<String, dynamic>;
        final result = <String, double>{};
        
        for (String currency in targetCurrencies) {
          if (rates.containsKey(currency)) {
            result[currency] = (rates[currency] as num).toDouble();
          }
        }
        
        return result;
      }
      return null;
    } catch (e) {
      print('Error fetching multi-currency rates: $e');
      return null;
    }
  }
    // Fetch metal prices (gold, silver, etc.) with multiple fallbacks
  static Future<Map<String, dynamic>?> getMetalPrices() async {
    try {
      // Primary: Using metals.live free API
      const url = 'https://api.metals.live/v1/spot';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Metal prices from metals.live: $data');
        return data;
      } else {
        print('Metals.live HTTP Error: ${response.statusCode}');
        // Fallback to approximate values if API fails
        return _getFallbackMetalPrices();
      }
    } catch (e) {
      print('Error fetching metal prices from metals.live: $e');
      // Fallback to approximate values if API fails
      return _getFallbackMetalPrices();
    }
  }
  
  // Fallback metal prices (approximate current values)
  static Map<String, dynamic> _getFallbackMetalPrices() {
    print('Using fallback metal prices');
    return {
      'XAU': 2000.0, // Gold ~$2000/oz
      'XAG': 25.0,   // Silver ~$25/oz
      'XPT': 1000.0, // Platinum ~$1000/oz
      'XPD': 1200.0, // Palladium ~$1200/oz
    };
  }
    // Convert metal price to different currency
  static Future<double?> convertMetalPrice({
    required double priceInUSD,
    required String targetCurrency,
  }) async {
    if (targetCurrency == 'USD') return priceInUSD;
    
    try {
      print('API Service: Converting $priceInUSD USD to $targetCurrency');
      
      final rates = await getMultiCurrencyRates(
        baseCurrency: 'USD',
        targetCurrencies: [targetCurrency],
      );
      
      print('API Service: Exchange rates received: $rates');
      
      if (rates != null && rates.containsKey(targetCurrency)) {
        final convertedPrice = priceInUSD * rates[targetCurrency]!;
        print('API Service: Converted price: $convertedPrice');
        return convertedPrice;
      }
      print('API Service: No exchange rate found for $targetCurrency');
      return null;
    } catch (e) {
      print('API Service error in convertMetalPrice: $e');
      return null;
    }
  }
    // Fetch specific metal price in specific currency
  static Future<double?> getMetalPriceInCurrency({
    required String metal, // XAU, XAG, XPT, XPD
    required String currency,
  }) async {
    try {
      print('API Service: Getting metal price for $metal in $currency');
      
      final metalData = await getMetalPrices();
      print('API Service: Metal data received: $metalData');
      
      if (metalData != null && metalData.containsKey(metal)) {
        final priceInUSD = (metalData[metal] as num).toDouble();
        print('API Service: $metal price in USD: $priceInUSD');
        
        final convertedPrice = await convertMetalPrice(
          priceInUSD: priceInUSD,
          targetCurrency: currency,
        );
        print('API Service: Converted price to $currency: $convertedPrice');
        
        return convertedPrice;
      }
      print('API Service: Metal $metal not found in data or data is null');
      return null;
    } catch (e) {
      print('API Service error in getMetalPriceInCurrency: $e');
      return null;
    }
  }
}
