import 'package:auto_size_text/auto_size_text.dart';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:gpsapp/main.dart';
import 'package:gpsapp/screens/home_screen.dart';
import 'package:gpsapp/screens/onboarding_screen.dart';
import 'package:gpsapp/widgets/error_dialog.dart';
import 'package:at_app_flutter/at_app_flutter.dart';

import 'package:flutter/material.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({Key? key}) : super(key: key);

  @override
  OnboardingDialogState createState() => OnboardingDialogState();
}

class OnboardingDialogState extends State<OnboardingDialog> {
  final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  List<String> _atSignsList = [];
  String? _atsign;

  @override
  void initState() {
    super.initState();
    initKeyChain();
  }

  Future<void> initKeyChain() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    if (atSignsList.isNotEmpty) {
      setState(() {
        _atSignsList = atSignsList;
        _atsign = atSignsList[0];
      });
    } else {
      setState(() {
        _atSignsList = atSignsList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_atSignsList.isNotEmpty) _previousOnboard(),
        _newOnboard(),
        if (_atSignsList.isNotEmpty) _resetButton(),
      ],
    );
  }

  Widget _previousOnboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              dropdownColor: Colors.white,
              value: _atsign,
              style: const TextStyle(
                  // fontFamily: 'LED',
                  fontSize: 30,
                  letterSpacing: 5,
                  color: Colors.black),
              items: _atSignsList
                  .map((atsign) => DropdownMenuItem(
                        value: atsign,
                        child: SizedBox(
                            width: 210,
                            child: AutoSizeText(
                              atsign.toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                            )),
                      ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _atsign = value;
                  });
                }
              },
            ),
            Row(
              children: const [
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            _onboard(_atsign!, "Go!")
          ],
        ),
      ],
    );
  }

  Widget _newOnboard() {
    return _onboard('@', "Setup new atSign");
  }

  Widget _onboard(String atSign, String text) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.green,
          textStyle: const TextStyle(
              // fontFamily: 'LED',
              fontSize: 30,
              letterSpacing: 5,
              color: Colors.white),
        ),
        
        onPressed: () async {
          var atClientPreference = await loadAtClientPreference();
          final result = await AtOnboarding.onboard(
            context: context,
            atsign: atSign,
            config: AtOnboardingConfig(
              hideQrScan: true,
              atClientPreference: atClientPreference,
              domain: AtEnv.rootDomain,
              rootEnvironment: AtEnv.rootEnvironment,
              appAPIKey: AtEnv.appApiKey,
              
            ),
          );
          switch (result.status) {
            case AtOnboardingResultStatus.success:
              _atsign = result.atsign;
              
                Navigator.pushNamed(context, HomeScreen.id);
              
              break;
            case AtOnboardingResultStatus.error:
                Navigator.pushNamed(context, OnboardingScreen.id);
              _handleError(context);
              break;
            case AtOnboardingResultStatus.cancel:
              
                Navigator.pushNamed(context, OnboardingScreen.id);
              
              break;
          }
        },
    child:      
      Text(text));


  }

  void _handleError(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ErrorDialog(
        'Unable to Onboard',
        'Please try again later!',
        [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(OnboardingScreen.id);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _resetButton() {
    return Column(
      children: [
        const SizedBox(height: 100),
        ElevatedButton(
          onPressed: () {
            _showResetDialog(context, false);
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
          child: const Text(
            "Reset atSigns",
            style: TextStyle(
              color: Colors.white,
              // fontFamily: 'LED',
              fontSize: 20,
              letterSpacing: 5,
            ),
          ),
        ),
      ],
    );
  }

  _showResetDialog(BuildContext context, bool shouldPop) {
    if (shouldPop) Navigator.pop(context);
    showDialog(context: context, builder: _resetAtsignDialog);
  }

  Widget _resetAtsignDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Reset your atSigns",
          style: TextStyle(
            color: Colors.black,
            // fontFamily: 'LED',
            fontSize: 30,
            letterSpacing: 5,
          )),
      content: SizedBox(
        height: 360,
        width: 360,
        child: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _atSignsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  AutoSizeText(
                    _atSignsList[index].toLowerCase(),
                    minFontSize: 10,
                    maxFontSize: 30,
                    textAlign: TextAlign.right,
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: const Text("Reset",
                        style: TextStyle(
                          color: Colors.white,
                          // fontFamily: 'LED',
                          fontSize: 20,
                          letterSpacing: 5,
                        )),
                    onPressed: () => _resetAtSign(_atSignsList[index]),
                  )
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
                style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
              ),     
          child: const Text('Cancel',
              style: TextStyle(
                color: Colors.white,
                // fontFamily: 'LED',
                fontSize: 30,
                letterSpacing: 5,
              )),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _resetAtSign(String atsign) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Confirmation"),
          content: Text("Are you sure you want to reset $atsign?"),
          actions: [
            TextButton(
                style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
              ),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _showResetDialog(context, true);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text("Reset", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _showResetDialog(context, true);
                _keyChainManager.deleteAtSignFromKeychain(atsign);
                setState(() {
                  if (_atSignsList.length == 1) {
                    _atsign = null;
                  }
                  if (_atSignsList.length > 1 && _atsign == atsign) {
                    _atsign = _atSignsList.firstWhere((element) => element != atsign);
                  }
                  _atSignsList.remove(atsign);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reset $atsign',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
