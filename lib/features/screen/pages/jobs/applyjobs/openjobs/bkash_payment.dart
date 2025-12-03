import 'package:flutter/material.dart';

class FakeBkashCheckout extends StatefulWidget {
  final String amount;

  const FakeBkashCheckout({super.key, required this.amount});

  @override
  State<FakeBkashCheckout> createState() => _FakeBkashCheckoutState();
}

class _FakeBkashCheckoutState extends State<FakeBkashCheckout> {
  int step = 1; // 1=Phone, 2=OTP, 3=PIN

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final pinController = TextEditingController();

  bool loading = false;

  Future<void> _nextStep() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => loading = false);

    if (step < 3) {
      setState(() => step++);
    } else {
      Navigator.pop(context, true);
    }
  }

  void _close() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 198, 17, 117), // FULL WHITE PAGE BACKGROUND
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFE2136E)),
        title: const Text(
          "Pay With Bkash",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2136E),
          ),
        ),
      ),

      body: SingleChildScrollView(                  
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            
            children: [
              const SizedBox(height: 120),

              _buildBkashCard(),                    
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //  MAIN CARD 

  Widget _buildBkashCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),                     
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // bKash Logo Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              "বিকাশ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE2136E),
              ),
            ),
          ),

          Container(height: 2, color: const Color(0xFFE2136E)),

          if (step == 1) _buildPhoneStep(),
          if (step == 2) _buildOtpStep(),
          if (step == 3) _buildPinStep(),

          // Hotline footer inside card
          Container(
            color: Colors.grey.shade100,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Center(
              child: Text(
                "16247",
                style: TextStyle(
                  color: Color(0xFFE2136E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REUSABLE TOP MERCHANT ROW 

  Widget _merchantRow() {
    return Row(
      children: [
        // Country badge
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          alignment: Alignment.center,
          child: const Text(
            "BD",
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("ShohoKaz",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text("Invoice: 1526",
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),

        Text(
          "৳${widget.amount}",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  //  STEP 1: Phone 

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          _merchantRow(),
          const SizedBox(height: 20),

          const Text(
            "Enter your bKash mobile number",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "01XXXXXXXXX",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 20),
          _bottomButtons("CLOSE", "NEXT", _close, _nextStep),
        ],
      ),
    );
  }

  //  STEP 2: OTP 
  Widget _buildOtpStep() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _merchantRow()),

        // Pink gradient area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE2136E), Color(0xFFB40C56)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Text(
                "Enter verification code sent to\n${phoneController.text.isNotEmpty ? phoneController.text : "01X ** *** ***"}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: otpController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: "",
                    hintText: "bKash Verification Code",
                  ),
                ),
              ),

              const SizedBox(height: 6),
              Text(
                "Didn't receive code? Resend code in 9s",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        _bottomButtons("CLOSE", "CONFIRM", _close, _nextStep),
      ],
    );
  }

  // STEP 3: PIN 

  Widget _buildPinStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          _merchantRow(),
          const SizedBox(height: 20),

          const Text(
            "Enter bKash PIN",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: pinController,
            maxLength: 5,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 18),
          _bottomButtons("CLOSE", "CONFIRM", _close, _nextStep),
        ],
      ),
    );
  }

  //  BOTTOM BUTTON BAR 

  Widget _bottomButtons(
      String left, String right, VoidCallback onLeft, VoidCallback onRight) {
    return Column(
      children: [
        Container(height: 1, color: Colors.grey.shade300),
        SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: loading ? null : onLeft,
                  child: Text(
                    left,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                child: TextButton(
                  onPressed: loading ? null : onRight,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE2136E),
                          ),
                        )
                      : Text(
                          right,
                          style: const TextStyle(
                            color: Color(0xFFE2136E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
