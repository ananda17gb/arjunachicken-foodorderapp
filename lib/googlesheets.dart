import 'package:arjunaschiken/ordersheetscolumn.dart';
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Order {
  static String _sheetId = dotenv.env['SHEET_ID']!;
  static String _sheetCredentials = '''
  {
    "type": "${dotenv.env['SHEET_TYPE']}",
    "project_id": "${dotenv.env['SHEET_PROJECT_ID']}",
    "private_key_id": "${dotenv.env['SHEET_PRIVATE_KEY_ID']}",
    "private_key": "${dotenv.env['SHEET_PRIVATE_KEY']}",
    "client_email": "${dotenv.env['SHEET_CLIENT_EMAIL']}",
    "client_id": "${dotenv.env['SHEET_CLIENT_ID']}",
    "auth_uri": "${dotenv.env['SHEET_AUTH_URI']}",
    "token_uri": "${dotenv.env['SHEET_TOKEN_URI']}",
    "auth_provider_x509_cert_url": "${dotenv.env['SHEET_AUTH_PROVIDER_X509_CERT_URL']}",
    "client_x509_cert_url": "${dotenv.env['SHEET_CLIENT_X509_CERT_URL']}",
    "universe_domain": "${dotenv.env['SHEET_UNIVERSE_DOMAIN']}"
  }
  ''';

  static Worksheet? _userSheet;
  static final _gsheets = GSheets(_sheetCredentials);

  static Future init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_sheetId);

      _userSheet = await _getWorkSheet(spreadsheet, title: "Orders");
      final firstRow = SheetsColumn.getColumns();
      _userSheet!.values.insertRow(1, firstRow);
    } catch (e) {
      print(e);
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }

  static Future insert(List<Map<String, dynamic>> rowList) async {
    _userSheet!.values.map.appendRows(rowList);
  }
}
