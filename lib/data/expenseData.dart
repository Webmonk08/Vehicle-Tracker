import 'package:my_app/service/supabaseService.dart';
import 'package:my_app/modals/expenseModal.dart';

class ExpenseService {
  final SupabaseClient = SupabaseService.client;

  Future<List<String>> getVehicleNumbers() async {
    try {
      final response = await SupabaseClient.from(
        'vehicles',
      ).select('VehicleNo');

      final vehicles = (response as List)
          .map((row) => row['VehicleNo'].toString())
          .toList();
      return vehicles;
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  Future<bool> addExpense(Expensemodal expense) async {
    try {
      String? vehicleId;

      print('Adding log for vehicle: ${expense.vehicleNo}');

      // Get vehicle ID
      final vehicleRes = await SupabaseClient.from(
        'vehicles',
      ).select('id').eq('VehicleNo', expense.vehicleNo).maybeSingle();

      if (vehicleRes == null) {
        print("❌ No vehicle found with number: ${expense.vehicleNo}");
        return false;
      } else {
        print("object");
        vehicleId = vehicleRes['id'].toString();
      }

      // Insert the log
      final logData = {
        'date': expense.date,
        'vehicle_id': vehicleId,
        'expense': expense.expense,
        'description': expense.description,
      };

      await SupabaseClient.from('Expense').insert(logData);
      print('✅ Log added successfully');
      return true;
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  /// Get all expenses
  Future<List<Expensemodal>> getAllExpenses() async {
    try {
      final response = await SupabaseClient.from('Expense').select('''
    vehicles!inner(VehicleNo),
    description,
    date,
    expense
  ''');
      return (response as List)
          .map((json) => Expensemodal.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching expenses: $e');
      rethrow;
    }
  }

  /// Filter expenses by optional vehicle ID and date range
  Future<List<Expensemodal>> filterExpenses({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = SupabaseClient.from('Expense').select();

      if (vehicleId != null) {
        query = query.eq('vehicle_id', vehicleId);
      }

      if (startDate != null && endDate != null) {
        query = query
            .gte('date', startDate.toIso8601String())
            .lte('date', endDate.toIso8601String());
      }

      final response = await query;

      return (response as List)
          .map((json) => Expensemodal.fromMap(json))
          .toList();
    } catch (e) {
      print('Error filtering expenses: $e');
      rethrow;
    }
  }
}
