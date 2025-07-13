// lib/screens/carbon_footprint_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarbonFootprintScreen extends StatefulWidget {
  @override
  _CarbonFootprintScreenState createState() => _CarbonFootprintScreenState();
}

class _CarbonFootprintScreenState extends State<CarbonFootprintScreen> {
  final String _apiKey = '9LSFMTNbmVUfDAZVEjeQ';

  String _mode = 'Car';
  String _result = '';

  //–– Car
  List<Map<String, dynamic>> _makes = [];
  List<Map<String, dynamic>> _models = [];
  String? _selectedMakeId, _selectedModelId;
  double _carDistance = 0;

  //–– Electricity
  final List<String> _countries = ['us', 'ca'];
  final Map<String, List<String>> _states = {
    'us': ['ca', 'fl', 'ny', 'tx'],
    'ca': ['on', 'qc', 'bc'],
  };
  String _electricCountry = 'us', _electricState = 'ca', _electricUnit = 'kwh';
  double _electricValue = 0;

  //–– Fuel Combustion
  final List<Map<String, dynamic>> _fuelSources = [
    {
      'name': 'Bituminous Coal',
      'api': 'bit',
      'units': ['short_ton', 'btu'],
    },
    {
      'name': 'Distillate Fuel Oil',
      'api': 'dfo',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Jet Fuel',
      'api': 'jf',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Kerosene',
      'api': 'ker',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Lignite Coal',
      'api': 'lig',
      'units': ['short_ton', 'btu'],
    },
    {
      'name': 'Municipal Solid Waste',
      'api': 'msw',
      'units': ['short_ton', 'btu'],
    },
    {
      'name': 'Natural Gas',
      'api': 'ng',
      'units': ['thousand_cubic_feet', 'btu'],
    },
    {
      'name': 'Petroleum Coke',
      'api': 'pc',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Propane Gas',
      'api': 'pg',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Residual Fuel Oil',
      'api': 'rfo',
      'units': ['gallon', 'btu'],
    },
    {
      'name': 'Subbituminous Coal',
      'api': 'sub',
      'units': ['short_ton', 'btu'],
    },
    {
      'name': 'Tire-Derived Fuel',
      'api': 'tdf',
      'units': ['short_ton', 'btu'],
    },
    {
      'name': 'Waste Oil',
      'api': 'wo',
      'units': ['barrel', 'btu'],
    },
  ];
  String _fuelSourceApi = 'bit';
  List<String> _fuelUnitOptions = [];
  String _fuelUnit = '';
  double _fuelValue = 0;

  //–– Shipping
  final List<String> _shipMethods = ['truck', 'ship', 'plane', 'train'];
  final List<String> _weightUnits = ['g', 'kg', 'lb'];
  final List<String> _distUnits = ['mi', 'km'];
  String _shipMethod = 'truck', _shipWeightUnit = 'kg', _shipDistUnit = 'km';
  double _shipWeightValue = 0, _shipDistValue = 0;

  @override
  void initState() {
    super.initState();
    _loadMakes(); // Load vehicle makes right away
    _updateFuelUnits(_fuelSourceApi);
  }

  /// Fetches the list of vehicle makes from Carbon Interface, parses the JSON
  /// properly as Map<String, dynamic>, and populates `_makes`.
  Future<void> _loadMakes() async {
    final response = await http.get(
      Uri.parse('https://www.carboninterface.com/api/v1/vehicle_makes'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) {
      // 1) Decode the entire JSON as a Map<String, dynamic>
      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      // 2) The "data" field is a List<dynamic>
      final List<dynamic> dataList = decoded['data'] as List<dynamic>;

      // 3) Convert each entry into a Map with "id" and "name"
      setState(() {
        _makes =
            dataList.map((element) {
              // Each element itself is a map with structure:
              // { "type": "vehicle_make", "id": "...", "attributes": { "name": "..." } }
              final Map<String, dynamic> inner =
                  element as Map<String, dynamic>;
              final String id = inner['id'] as String;
              final String name =
                  (inner['attributes'] as Map<String, dynamic>)['name']
                      as String;
              return {'id': id, 'name': name};
            }).toList();
      });
    } else {
      // Optionally handle a non‐200 status code here
    }
  }

  /// Given a selected make ID, fetches the vehicle models for that make.
  Future<void> _loadModels(String makeId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.carboninterface.com/api/v1/vehicle_makes/$makeId/vehicle_models',
      ),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) {
      // 1) Decode JSON as a Map<String, dynamic>
      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      // 2) Extract the "data" list
      final List<dynamic> dataList = decoded['data'] as List<dynamic>;

      // 3) Convert each entry to a Map with "id" and "name"
      setState(() {
        _models =
            dataList.map((element) {
              final Map<String, dynamic> inner =
                  element as Map<String, dynamic>;
              final String id = inner['id'] as String;
              final String name =
                  (inner['attributes'] as Map<String, dynamic>)['name']
                      as String;
              return {'id': id, 'name': name};
            }).toList();
      });
    } else {
      // Optionally handle errors here.
    }
  }

  /// Updates the available units for the chosen fuel source.
  void _updateFuelUnits(String api) {
    final src = _fuelSources.firstWhere((f) => f['api'] == api);
    _fuelUnitOptions = List<String>.from(src['units'] as List<dynamic>);
    _fuelUnit = _fuelUnitOptions.first;
  }

  /// Builds the JSON body according to the selected category (Car, Electricity, etc.),
  /// then calls the POST endpoint to fetch the carbon estimate.
  Future<void> _calculate() async {
    setState(() => _result = 'Calculating…');
    final uri = Uri.parse('https://www.carboninterface.com/api/v1/estimates');
    Map<String, dynamic> body = {};

    switch (_mode) {
      case 'Car':
        if (_selectedModelId == null || _carDistance <= 0) {
          setState(() => _result = 'Select a model and enter distance.');
          return;
        }
        body = {
          'type': 'vehicle',
          'vehicle_model_id': _selectedModelId,
          'distance_unit': 'mi',
          'distance_value': _carDistance,
        };
        break;

      case 'Electricity':
        if (_electricValue <= 0) {
          setState(() => _result = 'Enter valid electricity usage.');
          return;
        }
        body = {
          'type': 'electricity',
          'electricity_unit': _electricUnit,
          'electricity_value': _electricValue,
          'country': _electricCountry,
          'state': _electricState,
        };
        break;

      case 'Fuel Combustion':
        if (_fuelValue <= 0) {
          setState(() => _result = 'Enter valid fuel amount.');
          return;
        }
        body = {
          'type': 'fuel_combustion',
          'fuel_source_type': _fuelSourceApi,
          'fuel_source_unit': _fuelUnit,
          'fuel_source_value': _fuelValue,
        };
        break;

      case 'Shipping':
        if (_shipWeightValue <= 0 || _shipDistValue <= 0) {
          setState(() => _result = 'Enter weight and distance.');
          return;
        }
        body = {
          'type': 'shipping',
          'transport_method': _shipMethod,
          'weight_unit': _shipWeightUnit,
          'weight_value': _shipWeightValue,
          'distance_unit': _shipDistUnit,
          'distance_value': _shipDistValue,
        };
        break;
    }

    // Send the POST with JSON body
    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final Map<String, dynamic> decoded = jsonDecode(resp.body);
      final attrs = decoded['data']['attributes'] as Map<String, dynamic>;
      setState(
        () =>
            _result = 'CO₂: ${attrs['carbon_kg']} kg (${attrs['carbon_mt']} t)',
      );
    } else {
      setState(() => _result = 'Error fetching estimate.');
    }
  }

  /// Generic helper to build a labeled dropdown.
  Widget _buildDropdown<T>(
    String label,
    T? val,
    List<T> items,
    ValueChanged<T?> onChanged,
  ) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label),
      value: val,
      isExpanded: true,
      items:
          items
              .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
              .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carbon Footprint'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 1) Mode selector
            _buildDropdown<String>(
              'Mode',
              _mode,
              ['Car', 'Electricity', 'Fuel Combustion', 'Shipping'],
              (v) => setState(() {
                _mode = v!;
                _result = '';
              }),
            ),

            //–– If “Car” is selected, show Make / Model / Distance
            if (_mode == 'Car') ...[
              SizedBox(height: 16),
              _buildDropdown<String>(
                'Make',
                _selectedMakeId,
                _makes.map((m) => m['id'] as String).toList(),
                (id) => setState(() {
                  _selectedMakeId = id;
                  _selectedModelId = null;
                  _models = [];
                  if (id != null) _loadModels(id);
                }),
              ),
              if (_models.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDropdown<String>(
                  'Model',
                  _selectedModelId,
                  _models.map((m) => m['id'] as String).toList(),
                  (id) => setState(() => _selectedModelId = id),
                ),
              ],
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Distance (mi)'),
                keyboardType: TextInputType.number,
                onChanged: (t) => _carDistance = double.tryParse(t) ?? 0,
              ),
            ],

            //–– If “Electricity” is selected, show Country / State / Unit / Usage
            if (_mode == 'Electricity') ...[
              SizedBox(height: 16),
              _buildDropdown(
                'Country',
                _electricCountry,
                _countries,
                (c) => setState(() => _electricCountry = c!),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                'State',
                _electricState,
                _states[_electricCountry]!,
                (s) => setState(() => _electricState = s!),
              ),
              SizedBox(height: 16),
              _buildDropdown('Unit', _electricUnit, [
                'kwh',
                'mwh',
              ], (u) => setState(() => _electricUnit = u!)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Usage ($_electricUnit)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (t) => _electricValue = double.tryParse(t) ?? 0,
              ),
            ],

            //–– If “Fuel Combustion” is selected, show Fuel Source / Unit / Amount
            if (_mode == 'Fuel Combustion') ...[
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Fuel Source'),
                value: _fuelSourceApi,
                items:
                    _fuelSources.map((f) {
                      return DropdownMenuItem<String>(
                        value: f['api'] as String,
                        child: Text(f['name'] as String),
                      );
                    }).toList(),
                onChanged: (api) {
                  setState(() {
                    _fuelSourceApi = api!;
                    _updateFuelUnits(api);
                  });
                },
              ),
              SizedBox(height: 16),
              _buildDropdown<String>(
                'Unit',
                _fuelUnit,
                _fuelUnitOptions,
                (u) => setState(() => _fuelUnit = u!),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Amount ($_fuelUnit)'),
                keyboardType: TextInputType.number,
                onChanged: (t) => _fuelValue = double.tryParse(t) ?? 0,
              ),
            ],

            //–– If “Shipping” is selected, show Method / Weight / Distance / Units
            if (_mode == 'Shipping') ...[
              SizedBox(height: 16),
              _buildDropdown(
                'Method',
                _shipMethod,
                _shipMethods,
                (m) => setState(() => _shipMethod = m!),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                'Weight Unit',
                _shipWeightUnit,
                _weightUnits,
                (u) => setState(() => _shipWeightUnit = u!),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Weight ($_shipWeightUnit)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (t) => _shipWeightValue = double.tryParse(t) ?? 0,
              ),
              SizedBox(height: 16),
              _buildDropdown(
                'Distance Unit',
                _shipDistUnit,
                _distUnits,
                (d) => setState(() => _shipDistUnit = d!),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Distance ($_shipDistUnit)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (t) => _shipDistValue = double.tryParse(t) ?? 0,
              ),
            ],

            SizedBox(height: 24),
            ElevatedButton(onPressed: _calculate, child: Text('Calculate')),
            if (_result.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
