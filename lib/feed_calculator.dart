import 'package:flutter/material.dart';

import 'database_helper.dart';

class FeedCalculator extends StatefulWidget {
  const FeedCalculator({super.key});

  @override
  _FeedCalculatorState createState() => _FeedCalculatorState();
}

class _FeedCalculatorState extends State<FeedCalculator> {
  // Controllers for user input
  final _ageController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedBreed;
  String? _selectedType;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Expanded formulations map
  Map<String, Map<String, dynamic>> formulations = {
    'broilers': {
      '1-4': {
        'maize': 7.2,
        'maize_germ': 11.9,
        'wheat_pollard': 9.5,
        'wheat_bran': 7.2,
        'cotton_seed_cake': 4.3,
        'sunflower_cake': 3.4,
        'fishmeal': 2.1,
        'lime': 1.4,
        'soya_meal': 2.5,
        'bone_meal': 0.045,
        'grower_pmx': 0.010,
        'salt': 0.005,
        'coccidiostat': 0.005,
        'zincbacitrach': 0.005,
      },
      '5-8': {
        'maize': 28.6,
        'maize_germ': 8.6,
        'wheat_pollard': 10.0,
        'wheat_bran': 6.0,
        'cotton_seed_cake': 5.0,
        'sunflower_cake': 3.0,
        'fishmeal': 8.6,
        'lime': 2.9,
        'soya_meal': 10.0,
        'bone_meal': 0.045,
        'grower_pmx': 0.010,
        'salt': 0.005,
        'coccidiostat': 0.005,
        'zincbacitrach': 0.005,
      },
    },
    'layers': {
      '1-4': {
        'maize': 22.5,
        'wheat_bran': 6.5,
        'wheat_pollard': 5.0,
        'sunflower': 12.0,
        'fishmeal': 1.1,
        'lime': 1.25,
        'salt': 0.030,
        'premix': 0.020,
        'tryptophan': 0.070,
        'lysine': 0.003,
        'methionine': 0.010,
        'threonine': 0.070,
        'enzymes': 0.050,
        'coccidiostat': 0.060,
        'toxin_binder': 0.050,
      },
      '18+': {
        'maize': 24.3,
        'soya': 8.6,
        'fishmeal': 5.7,
        'bran': 7.1,
        'lime': 4.3,
        'premix': 0.180,
        'lysine': 0.070,
        'methionine': 0.035,
        'threonine': 0.070,
        'tryptophan': 0.035,
        'toxin_binder': 0.050,
      },
    },
    'noilers': {
      '1-4': {
        'maize': 20.0,
        'wheat_bran': 5.0,
        'wheat_pollard': 4.0,
        'sunflower': 10.0,
        'fishmeal': 1.5,
        'lime': 1.0,
        'salt': 0.025,
        'premix': 0.015,
        'lysine': 0.003,
        'threonine': 0.065,
        'methionine': 0.008,
        'enzymes': 0.040,
        'coccidiostat': 0.050,
      },
      '5-8': {
        'maize': 25.0,
        'wheat_bran': 6.0,
        'wheat_pollard': 5.0,
        'sunflower': 11.0,
        'fishmeal': 2.5,
        'lime': 1.5,
        'salt': 0.030,
        'premix': 0.020,
        'lysine': 0.005,
        'threonine': 0.070,
        'methionine': 0.010,
        'enzymes': 0.050,
        'coccidiostat': 0.060,
      },
    },
    'turkey': {
      '1-4': {
        'maize': 15.0,
        'wheat_bran': 4.5,
        'wheat_pollard': 3.5,
        'sunflower': 8.0,
        'fishmeal': 1.0,
        'lime': 1.0,
        'salt': 0.020,
        'premix': 0.015,
        'lysine': 0.003,
        'threonine': 0.060,
        'methionine': 0.007,
        'enzymes': 0.030,
        'coccidiostat': 0.050,
      },
      '5-8': {
        'maize': 20.0,
        'wheat_bran': 5.5,
        'wheat_pollard': 4.0,
        'sunflower': 9.0,
        'fishmeal': 1.5,
        'lime': 1.5,
        'salt': 0.025,
        'premix': 0.020,
        'lysine': 0.005,
        'threonine': 0.065,
        'methionine': 0.008,
        'enzymes': 0.040,
        'coccidiostat': 0.060,
      },
      '9-16': {
        'maize': 25.0,
        'wheat_bran': 6.0,
        'wheat_pollard': 5.0,
        'sunflower': 10.0,
        'fishmeal': 2.0,
        'lime': 2.0,
        'salt': 0.030,
        'premix': 0.025,
        'lysine': 0.006,
        'threonine': 0.070,
        'methionine': 0.010,
        'enzymes': 0.050,
        'coccidiostat': 0.080,
      },
    },
  };

  void _calculateFeed() async {
    // Validate inputs
    if (_selectedType == null ||
        _ageController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    int age;
    int amount;

    try {
      age = int.parse(_ageController.text);
      amount = int.parse(_amountController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid numbers for age and amount!')),
      );
      return;
    }

    String ageGroup;

    if (_selectedType == 'broilers') {
      ageGroup = (age <= 4) ? '1-4' : '5-8';
    } else if (_selectedType == 'layers') {
      ageGroup = (age < 18) ? '1-4' : '18+';
    } else if (_selectedType == 'noilers') {
      ageGroup = (age <= 4) ? '1-4' : '5-8';
    } else if (_selectedType == 'turkey') {
      if (age <= 4) {
        ageGroup = '1-4';
      } else if (age <= 8) {
        ageGroup = '5-8';
      } else {
        ageGroup = '9-16';
      }
    } else {
      return; // Handle case where no breed is selected
    }

    Map<String, dynamic>? formulation = formulations[_selectedType]?[ageGroup];
    if (formulation != null) {
      String result = 'For $_selectedType ($age weeks):\n';
      formulation.forEach((key, value) {
        result += '$key: ${(value as double) * amount} kg\n';
      });

      // Save formulation to database
      try {
        await _dbHelper.insertFormulation(
            _selectedType!, ageGroup, amount, result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Formulation saved successfully! please check for the formulated data')),
        );

        // Display result
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Formulated Feeds'),
              content: Text(result),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save formulation: $e')),
        );
      }
    } else {
      // Handle case where no formulation is found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No formulation found for the selected inputs')),
      );
    }
  }

  Future<void> _showSavedFormulations() async {
    try {
      final savedFormulations = await _dbHelper.getFormulations();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Saved Formulations'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: savedFormulations.length,
                itemBuilder: (context, index) {
                  final formulation = savedFormulations[index];
                  return ListTile(
                    title: Text(formulation['formulation']),
                    subtitle: Text(
                        '${formulation['type']} (${formulation['age']} weeks) - Amount: ${formulation['amount']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          await _dbHelper.deleteFormulation(formulation['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Formulation deleted successfully!')),
                          );
                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to delete formulation: $e')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve saved formulations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Formulation Calculator by KASU/19/CSC/1069'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showSavedFormulations,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Type of Poultry Bird'),
                    items: const [
                      DropdownMenuItem(
                          value: 'broilers', child: Text('Broilers')),
                      DropdownMenuItem(value: 'layers', child: Text('Layers')),
                      DropdownMenuItem(
                          value: 'noilers', child: Text('Noilers')),
                      DropdownMenuItem(value: 'turkey', child: Text('Turkey')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age (weeks)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount of Birds',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.pets),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add visual feedback on button press
                      _calculateFeed();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: const Color.fromARGB(255, 43, 244, 25),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 18), // Text color
                    ),
                    child: const Text('Calculate Formulation'),
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'Calculate the feed formulation based on input',
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Provide the age and amount of birds to calculate the feed formulation.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
