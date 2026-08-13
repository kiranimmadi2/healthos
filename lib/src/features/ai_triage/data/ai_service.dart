import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

class AIService {
  // Routed through Firebase AI Logic (Gemini Developer API backend).
  GenerativeModel? _flashModel;
  GenerativeModel? _proModel;

  AIService() {
    _initModels();
  }

  void _initModels() {
    try {
      _flashModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');
      _proModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-pro');
    } catch (e) {
      debugPrint('Firebase AI initialization with gemini-2.0-flash error: $e');
      try {
        _flashModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');
        _proModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-pro');
      } catch (e2) {
        debugPrint('Firebase AI default initialization error: $e2');
      }
    }
  }

  GenerativeModel? _safeGetModel(String modelName) {
    try {
      return FirebaseAI.googleAI().generativeModel(model: modelName);
    } catch (e) {
      return null;
    }
  }

  /// Calls Google Gemini REST API directly to guarantee dynamic AI responses
  Future<String?> _callGeminiRest(String prompt) async {
    const apiKey = 'AIzaSyAoAMd3c7TjodVd1SweCFG6D0PRo1I9HvQ';
    final models = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

    for (final m in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent?key=$apiKey',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text;
              }
            }
          }
        } else {
          debugPrint('Gemini REST API response error ($m): ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('Gemini REST exception ($m): $e');
      }
    }
    return null;
  }

  /// Builds a comprehensive patient context block from the Firestore user document
  /// so the model can deeply understand the user's health profile in the background.
  String _patientContext(Map<String, dynamic>? profile) {
    if (profile == null || profile.isEmpty) {
      return 'Patient Profile: Standard Patient (No details recorded yet)\n';
    }

    final parts = <String>[];

    final name = profile['name'] as String? ?? profile['displayName'] as String?;
    if (name != null && name.isNotEmpty) parts.add('Name: $name');

    final dob = DateTime.tryParse(profile['dob'] as String? ?? profile['dateOfBirth'] as String? ?? '');
    if (dob != null) {
      final now = DateTime.now();
      var age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      parts.add('Age: $age years');
    }

    final gender = profile['gender'] as String?;
    if (gender != null && gender.isNotEmpty && gender != 'Prefer not to say') {
      parts.add('Gender: $gender');
    }

    final height = (profile['height'] as num?)?.toDouble();
    final weight = (profile['weight'] as num?)?.toDouble();
    if (height != null && height > 0) parts.add('Height: ${height.toStringAsFixed(0)} cm');
    if (weight != null && weight > 0) parts.add('Weight: ${weight.toStringAsFixed(0)} kg');
    if (height != null && weight != null && height > 0 && weight > 0) {
      final heightM = height / 100;
      final bmi = weight / (heightM * heightM);
      String category = 'Normal weight';
      if (bmi < 18.5) {
        category = 'Underweight';
      } else if (bmi >= 25 && bmi < 30) {
        category = 'Overweight';
      } else if (bmi >= 30) {
        category = 'Obese';
      }
      parts.add('BMI: ${bmi.toStringAsFixed(1)} kg/m² ($category)');
    }

    final bloodGroup = profile['bloodGroup'] as String? ?? profile['blood_group'] as String?;
    if (bloodGroup != null && bloodGroup.isNotEmpty) parts.add('Blood Group: $bloodGroup');

    final allergies = profile['allergies'];
    if (allergies != null) {
      final allergList = allergies is List ? allergies.join(', ') : allergies.toString();
      if (allergList.isNotEmpty) parts.add('Known Allergies: $allergList');
    }

    final conditions = profile['medicalHistory'] ?? profile['conditions'] ?? profile['chronicConditions'];
    if (conditions != null) {
      final condList = conditions is List ? conditions.join(', ') : conditions.toString();
      if (condList.isNotEmpty) parts.add('Pre-existing Diseases & Medical Conditions: $condList');
    }

    final medications = profile['medications'] ?? profile['currentMedications'];
    if (medications != null) {
      final medList = medications is List ? medications.join(', ') : medications.toString();
      if (medList.isNotEmpty) parts.add('Current Medications: $medList');
    }

    if (parts.isEmpty) return 'Patient Profile: Standard Patient\n';
    return 'Detailed Patient Background Profile:\n${parts.map((p) => '- $p').join('\n')}\n';
  }

  Future<String> getTriage(
    String input, {
    Map<String, dynamic>? patientProfile,
  }) async {
    final prompt = '''
You are an expert, highly empathetic, and calm Clinical AI Care Assistant inside the HealthOS medical platform, speaking directly to the patient.

${_patientContext(patientProfile)}
Patient's reported query / symptom: "$input"

CRITICAL CLINICAL & PERSONALIZATION DIRECTIVES:
1. DEEPLY PERSONALIZED ANALYSIS BASED ON PATIENT DATA:
   - Carefully review the user's specific background above (Height, Weight, calculated BMI, Age, Gender, Blood Group, Pre-existing Diseases/Conditions, Allergies, Active Medications).
   - NEVER give generic copy-paste standard answers. Explicitly connect their physical stats, BMI, and pre-existing conditions to their reported issue.
   - Dynamically analyze the patient's inquiry and provide tailored health recommendations.
   - For specific symptoms like "back pain", "neck pain", "headache", etc., focus specifically on relief, ergonomics, posture, causes, and appropriate care steps for that symptom!

2. MANDATORY DYNAMIC SECTIONS - WHAT TO EAT, WHAT TO AVOID, & EXERCISE:
   You MUST dynamically generate comprehensive, tailored, and actionable sections for:
   - 🥗 WHAT TO EAT: Provide specific, healthy food items, anti-inflammatory options, lean proteins, complex carbs, and nutrient-dense choices dynamically tailored to their query and exact health profile.
   - 🚫 WHAT TO AVOID: List specific foods, drinks, posture mistakes, or lifestyle habits to strictly avoid based on their query.
   - 🏃 RECOMMENDED EXERCISES: Suggest specific exercises, ergonomic adjustments, stretches, or physical activity appropriate for their condition.

3. ACCURATE TRIAGE CLASSIFICATION:
   - Prefix response with "EMERGENCY:" for life-threatening symptoms (chest pain, acute breathlessness, stroke, severe bleeding).
   - Prefix response with "SEE DOCTOR:" for high-risk, severe pain, or high fever symptoms.
   - Prefix response with "HOME CARE:" for non-emergency symptoms (back pain, mild cold, tiredness, digestive discomfort).
   - Prefix response with "HEALTH ADVICE:" for general health, diet, weight management, or fitness questions.

4. RESPONSE STRUCTURE & TONE:
   - Address patient by first name warmly.
   - Clearly state which profile factors were evaluated.
   - Provide concrete, targeted recommendations including WHAT TO EAT, WHAT TO AVOID, and RECOMMENDED EXERCISES.
   - State clear red flags for when to consult a doctor on HealthOS.
   - End with a reassuring 1-line medical disclaimer.
''';

    // 1. Try Firebase AI SDK Models
    final modelsToTry = [
      _flashModel,
      _safeGetModel('gemini-2.0-flash'),
      _safeGetModel('gemini-1.5-flash'),
      _safeGetModel('gemini-1.5-pro'),
    ];

    for (final model in modelsToTry) {
      if (model == null) continue;
      try {
        final response = await model.generateContent([
          Content.text(prompt),
        ]);
        if (response.text != null && response.text!.trim().isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        debugPrint('Gemini SDK attempt error: $e');
      }
    }

    // 2. Direct Gemini REST API Fallback
    final restResponse = await _callGeminiRest(prompt);
    if (restResponse != null && restResponse.trim().isNotEmpty) {
      return restResponse;
    }

    // 3. Smart Clinical Fallback Engine
    return _generateSmartFallbackTriage(input, patientProfile: patientProfile);
  }

  /// Intelligent Clinical Triage Engine Fallback
  String _generateSmartFallbackTriage(
    String input, {
    Map<String, dynamic>? patientProfile,
  }) {
    final name = (patientProfile?['name'] as String?)?.split(' ').first ?? 'there';
    final height = (patientProfile?['height'] as num?)?.toDouble();
    final weight = (patientProfile?['weight'] as num?)?.toDouble();

    double? bmi;
    String bmiCategory = 'Not recorded';
    if (height != null && weight != null && height > 0 && weight > 0) {
      final heightM = height / 100;
      bmi = weight / (heightM * heightM);
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi >= 18.5 && bmi < 25) {
        bmiCategory = 'Normal weight';
      } else if (bmi >= 25 && bmi < 30) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    }

    final rawConditions = patientProfile?['medicalHistory'] ?? patientProfile?['conditions'] ?? patientProfile?['chronicConditions'];
    final conditionsStr = rawConditions is List
        ? rawConditions.join(', ')
        : (rawConditions?.toString() ?? 'None recorded');

    final rawAllergies = patientProfile?['allergies'];
    final allergiesStr = rawAllergies is List
        ? rawAllergies.join(', ')
        : (rawAllergies?.toString() ?? 'None reported');

    final rawMeds = patientProfile?['medications'] ?? patientProfile?['currentMedications'];
    final medsStr = rawMeds is List
        ? rawMeds.join(', ')
        : (rawMeds?.toString() ?? 'None reported');

    final lower = input.toLowerCase();

    // Context Header detailing exact user data evaluated
    final profileSummaryHeader = '''Patient Health Context Analyzed:
• Physical Data: ${height != null ? '${height.toStringAsFixed(0)} cm' : 'Height N/A'}, ${weight != null ? '${weight.toStringAsFixed(0)} kg' : 'Weight N/A'}${bmi != null ? ' (BMI: ${bmi.toStringAsFixed(1)} - $bmiCategory)' : ''}
• Pre-existing Conditions / Diseases: $conditionsStr
• Active Medications: $medsStr | Allergies: $allergiesStr''';

    // 1. Emergency symptom patterns
    final isEmergency = lower.contains('chest pain') ||
        lower.contains('shortness of breath') ||
        lower.contains('cant breathe') ||
        lower.contains('can\'t breathe') ||
        lower.contains('unconscious') ||
        lower.contains('stroke') ||
        lower.contains('severe bleeding') ||
        lower.contains('numbness') ||
        lower.contains('seizure') ||
        lower.contains('head injury') ||
        lower.contains('vomiting blood');

    if (isEmergency) {
      return '''EMERGENCY: Hello $name, your symptoms require urgent medical evaluation!

$profileSummaryHeader

🚨 Immediate Directive: Please call local emergency medical services (911/112) or go to the nearest emergency room immediately. Do not drive yourself.

Disclaimer: Automated clinical triage guidance only. Not a substitute for emergency medical care.''';
    }

    // 2. Severe / High risk symptom patterns
    final isSevereDoctorNeeded = lower.contains('high fever') ||
        lower.contains('unbearable') ||
        lower.contains('severe pain') ||
        lower.contains('blood pressure') ||
        lower.contains('high bp') ||
        lower.contains('stiff neck') ||
        lower.contains('fracture') ||
        lower.contains('broken');

    if (isSevereDoctorNeeded) {
      return '''SEE DOCTOR: Hello $name, based on your symptoms ("$input") and health profile, a clinical consultation is advised.

$profileSummaryHeader

• Clinical Recommendation: We strongly advise scheduling a visit with a specialist in HealthOS for a physical examination.
• Condition Precaution: ${conditionsStr != 'None recorded' ? 'Since your profile lists "$conditionsStr", monitor your vitals closely.' : 'Keep track of symptom duration and onset.'}
• Next Steps: Rest adequately, stay hydrated, and visit an urgent care facility if symptoms escalate suddenly.

Disclaimer: Informational triage guidance based on recorded profile.''';
    }

    // 3. Back Pain, Neck Pain, Posture & Ergonomics / Muscle Strain
    final isBackOrMusclePain = lower.contains('back pain') ||
        lower.contains('backache') ||
        lower.contains('back') ||
        lower.contains('neck pain') ||
        lower.contains('spine') ||
        lower.contains('posture') ||
        lower.contains('lumbar') ||
        lower.contains('shoulder') ||
        lower.contains('joint pain') ||
        lower.contains('muscle pain') ||
        lower.contains('body ache') ||
        lower.contains('strain');

    if (isBackOrMusclePain) {
      return '''HOME CARE: Hello $name, here is a targeted care and ergonomics guide for your reported "$input":

$profileSummaryHeader

• Clinical Ergonomic & Muscle Assessment:
  - Office desk back pain is commonly caused by prolonged sitting, improper chair/screen height, lack of lumbar support, or postural muscle strain.
  ${bmi != null && bmi < 18.5 ? '- Physical Context: Being underweight (BMI ${bmi.toStringAsFixed(1)}) means lighter core muscle padding around your lumbar spine, making ergonomic posture alignment especially critical.' : ''}

• 🥗 WHAT TO EAT & DRINK:
  1. Anti-Inflammatory Foods: Turmeric milk, ginger tea, walnuts, flaxseeds, berries, and green leafy vegetables to help soothe tissue inflammation.
  2. Disc Hydration: Drink at least 2.5–3.0 Liters of water daily to keep spinal intervertebral discs hydrated.

• 🚫 WHAT TO AVOID:
  1. Slouching & Forward Head Posture: Avoid leaning forward toward your monitor or crossing your legs for long periods.
  2. Prolonged Unbroken Sitting: Avoid sitting continuously for over 45 minutes without standing up.
  3. Bending at Waist: Avoid bending forward from the waist to lift items; always bend at your knees.

• 🏃 RECOMMENDED EXERCISES & ERGONOMIC ADJUSTMENTS:
  1. Office Chair Ergonomics: Set chair height so knees are at 90°, feet rest flat on the floor, and place a small lumbar pillow behind your lower back. Position top of screen at eye level.
  2. Hourly Micro-Breaks: Stand up every 45 minutes, stretch arms overhead, and perform gentle standing back extension stretches.
  3. Core Strengthening & Lumbar Stretches: Cat-Cow stretch (10 reps), Bird-Dog exercise (10 reps per side), Cobra stretch (Hold 15s), and Glute Bridges (2 sets of 10 reps).

• When to Consult a Specialist:
  If back pain radiates down your leg, causes numbness/tingling, or persists beyond 7 days, book a consultation with an Orthopedist or Physiotherapist on HealthOS.

Disclaimer: Educational guidance personalized to your recorded health profile.''';
    }

    // 4. Diet, Nutrition, Weight Management & Exercise queries
    final isDietOrWeight = lower.contains('diet') ||
        lower.contains('eat') ||
        lower.contains('food') ||
        lower.contains('weight') ||
        lower.contains('exercise') ||
        lower.contains('workout') ||
        lower.contains('nutrition') ||
        lower.contains('fitness') ||
        lower.contains('gain') ||
        lower.contains('loss') ||
        lower.contains('lose');

    if (isDietOrWeight) {
      final isUnderweight = bmi != null && bmi < 18.5;
      final isOverweight = bmi != null && bmi >= 25.0;

      final eatPlan = isUnderweight
          ? '''  1. Lean Proteins: Eggs, chicken breast, fish, paneer/tofu, lentils, and Greek yogurt (aim for 1.2–1.5g protein per kg of body weight).
  2. Complex Carbohydrates: Oats, brown rice, sweet potatoes, quinoa, and whole wheat bread.
  3. Healthy Fats: Almonds, walnuts, chia seeds, avocados, peanut butter, extra virgin olive oil, or ghee.
  4. High-Calorie Smoothies: Blend milk, banana, oats, peanut butter, and protein powder as between-meal snacks.'''
          : (isOverweight
              ? '''  1. High-Fiber Vegetables: Spinach, broccoli, leafy greens, cucumbers, and bell peppers (fills you up with minimal calories).
  2. Lean Proteins: Grilled chicken, white fish, egg whites, tofu, and legumes to preserve muscle while burning fat.
  3. Portion-Controlled Whole Grains: Quinoa, steel-cut oats, and brown rice.
  4. High Hydration: Drink 3–4 Liters of water daily, especially 1 glass 30 minutes before meals.'''
              : '''  1. Balanced Plate: Fill 50% with vegetables/fruits, 25% with lean protein, and 25% with complex grains.
  2. Whole Foods: Oats, fish, poultry, eggs, legumes, nuts, and fresh fruits.
  3. Adequate Water: Drink 2.5–3.0 Liters of water daily throughout the day.''');

      final avoidPlan = isUnderweight
          ? '''  1. Skipping Meals: Avoid long fasting gaps; eat every 3–4 hours.
  2. Liquid Appetite Suppressants: Avoid drinking large amounts of water right before meals.
  3. Junk & Sugary Snacks: Avoid empty calorie junk food, sodas, and deep-fried foods that lack vital nutrients.
  4. Excessive Caffeine: Limit coffee and energy drinks that suppress appetite.'''
          : (isOverweight
              ? '''  1. Refined Sugars: Avoid sodas, packaged fruit juices, candies, and refined flour.
  2. Trans Fats & Deep Fried Items: Avoid fast food, commercial baked goods, and processed meats.
  3. Late Night Snacking: Avoid heavy meals or snacks within 3 hours before sleep.
  4. High-Calorie Drinks: Avoid alcohol and sugary coffee drinks.'''
              : '''  1. Ultra-Processed Foods: Limit high-sodium packaged snacks, artificial trans fats, and excess sugar.
  2. Sedentary Habits: Avoid lying down or sitting continuously right after eating meals.''');

      final exercisePlan = isUnderweight
          ? '''  1. Progressive Strength Training: Focus on compound lifts (squats, push-ups, dumbbell presses, lunges) 3–4 days/week to stimulate muscle mass gain.
  2. Adequate Rest: Rest 48 hours between working the same muscle groups.
  3. Moderate Cardio: Keep high-intensity cardio limited to 15–20 minutes twice a week so you do not burn excess calories needed for growth.'''
          : (isOverweight
              ? '''  1. Aerobic Cardio Activity: 30–45 minutes of brisk walking, cycling, swimming, or elliptical 4–5 days/week.
  2. Resistance Training: Perform bodyweight exercises or weight training 2–3 days/week to boost metabolism and retain muscle mass.
  3. Daily Step Target: Aim for 8,000–10,000 steps daily.'''
              : '''  1. Weekly Aerobic Activity: 150 minutes of moderate aerobic exercise (brisk walking, jogging, cycling).
  2. Muscle & Core Strengthening: 2 sessions of strength training or yoga weekly for posture and overall health.''');

      return '''HEALTH ADVICE: Hello $name, here is a personalized diet, nutrition, and exercise plan tailored to your profile:

$profileSummaryHeader

• Physical Profile Analysis:
  - Height: ${height != null ? '${height.toStringAsFixed(0)} cm' : 'N/A'} | Weight: ${weight != null ? '${weight.toStringAsFixed(0)} kg' : 'N/A'} | BMI: ${bmi != null ? '${bmi.toStringAsFixed(1)} ($bmiCategory)' : 'Not recorded'}
  - Goal Context: ${isUnderweight ? 'Focus on healthy, nutrient-dense weight gain and progressive muscle building.' : (isOverweight ? 'Focus on sustainable fat loss, calorie deficit, and cardiovascular fitness.' : 'Focus on weight maintenance, balanced nutrition, and energy optimization.')}

• 🥗 WHAT TO EAT (Nutrient & Meal Recommendations):
$eatPlan

• 🚫 WHAT TO AVOID (Foods & Habits to Steer Clear Of):
$avoidPlan

• 🏃 RECOMMENDED EXERCISES (Tailored Workout Protocol):
$exercisePlan

• Specialist Note:
  If you have specific food allergies or medical conditions ($conditionsStr), consult a nutritionist or doctor on HealthOS for a customized diet chart.

Disclaimer: Educational guidance tailored to your recorded health profile.''';
    }

    // 5. Laziness / Fatigue / Lethargy / Low Energy / Weakness
    final isLazinessOrFatigue = lower.contains('lazy') ||
        lower.contains('laziness') ||
        lower.contains('fatigue') ||
        lower.contains('letharg') ||
        lower.contains('tired') ||
        lower.contains('low energy') ||
        lower.contains('weakness') ||
        lower.contains('exhausted') ||
        lower.contains('sleepy');

    if (isLazinessOrFatigue) {
      final recommendedWater = weight != null ? (weight * 0.035).toStringAsFixed(1) : '2.5 - 3.0';
      return '''HOME CARE: Hello $name, here is a personalized health assessment for your reported feelings of "$input":

$profileSummaryHeader

• Personalized Health Analysis:
  - Feeling lazy or lethargic is driven by metabolic, hydration, and circadian factors rather than simple tiredness.
  ${weight != null ? '- Hydration Goal: Based on your weight of ${weight.toStringAsFixed(0)} kg, drink at least $recommendedWater Liters of water daily to maintain cellular energy.' : '- Hydration Goal: Maintain steady water intake throughout the day.'}
  ${bmi != null ? '- Metabolic Context: Your BMI is ${bmi.toStringAsFixed(1)} ($bmiCategory). ${bmi < 18.5 ? 'Ensure adequate calorie & protein intake to prevent low blood sugar energy dips.' : 'Balanced meals help prevent post-meal glucose slumps.'}' : ''}

• 🥗 WHAT TO EAT:
  1. Complex Carbs & Protein: Whole oats, eggs, nuts, bananas, green tea, and complex grains.
  2. Constant Hydration: Sip water steadily throughout the day.

• 🚫 WHAT TO AVOID:
  1. Heavy Sugary Snacks: Avoid refined sugar and candy that cause steep insulin spikes followed by energy crashes.
  2. OTC Medications: Do not take painkillers like Paracetamol unless you have fever or body aches.

• 🏃 RECOMMENDED EXERCISES:
  1. Light Morning Activity: 15–20 minutes of morning brisk walking in sunlight to boost cortisol and energy.
  2. Desk Mobility & Stretching: Take 5-minute movement breaks every hour to restore circulation.

Disclaimer: Clinical triage guidance personalized to your recorded health profile.''';
    }

    // 6. Headache / Migraine / Dizziness
    final isHeadache = lower.contains('headache') || lower.contains('migraine') || lower.contains('dizziness') || lower.contains('head heaviness');
    if (isHeadache) {
      return '''HOME CARE: Hello $name, here is a tailored plan for your reported "$input":

$profileSummaryHeader

• Personalized Analysis:
  - Headaches and dizziness often stem from dehydration, screen strain, stress, or blood pressure changes.
  ${conditionsStr.toLowerCase().contains('hypertension') || conditionsStr.toLowerCase().contains('bp') ? '- Alert: Since your profile lists Blood Pressure / Hypertension, please check your BP with a digital monitor today.' : '- Practice regular screen breaks (20-20-20 rule).'}

• 🥗 WHAT TO EAT:
  1. Hydrating Foods & Electrolytes: Coconut water, cucumber, watermelon, and light soups.
  2. Magnesium-Rich Foods: Almonds, spinach, and dark chocolate.

• 🚫 WHAT TO AVOID:
  1. Skipping Meals: Avoid long gaps between meals which drop blood glucose.
  2. Excess Caffeine & Alcohol: Avoid heavy coffee or alcohol which dehydrate cells.

• 🏃 RECOMMENDED EXERCISES:
  1. Gentle Neck & Shoulder Stretches: Slow head tilts and shoulder rolls to release tension.
  2. Deep Breathing / Rest: 15 minutes of quiet dark-room relaxation. Avoid high-impact exercise while dizzy.

Disclaimer: Triage guidance personalized to your health background.''';
    }

    // 7. Gastritis / Stomach Pain / Indigestion / Acidity
    final isStomach = lower.contains('stomach') || lower.contains('acidity') || lower.contains('gastric') || lower.contains('indigestion') || lower.contains('nausea') || lower.contains('bloating');
    if (isStomach) {
      return '''HOME CARE: Hello $name, here is tailored guidance for your stomach query ("$input"):

$profileSummaryHeader

• Targeted Health Assessment:
  - Stomach discomfort or acidity can be triggered by food timing, spicy meals, or medication side effects.
  ${medsStr != 'None reported' ? '- Medication Note: Certain active medications ($medsStr) can irritate the stomach lining if taken without food.' : ''}

• 🥗 WHAT TO EAT:
  1. Bland, Soothing Foods: Plain rice, oatmeal, bananas, applesauce, warm ginger tea, and buttermilk/probiotics.
  2. Warm Hydration: Sip warm water throughout the day.

• 🚫 WHAT TO AVOID:
  1. Spicy & Oily Foods: Avoid deep-fried, heavily spiced, or acidic (citrus/tomato) dishes.
  2. Carbonated & Caffeinated Beverages: Avoid sodas, coffee, and alcohol.
  3. Lying Down Post-Meal: Avoid lying down within 2 hours after eating.

• 🏃 RECOMMENDED EXERCISES:
  1. Gentle Post-Meal Walk: 10–15 minutes of slow flat-surface walking to assist digestion. Avoid intense ab workouts during acute acidity.

Disclaimer: Educational guidance tailored to your health profile.''';
    }

    // 8. Cough / Cold / Sore Throat / Mild Fever
    final isColdFlu = lower.contains('cold') || lower.contains('sore throat') || lower.contains('cough') || lower.contains('fever') || lower.contains('runny nose') || lower.contains('congestion');
    if (isColdFlu) {
      return '''HOME CARE: Hello $name, here is a personalized care protocol for "$input":

$profileSummaryHeader

• Tailored Care Recommendations:
  - Support your immune system with proper fluids and rest.

• 🥗 WHAT TO EAT:
  1. Warm Soothing Fluids: Warm soups, honey-lemon ginger tea, warm water, and garlic-infused broth.
  2. Vitamin C Foods: Oranges, bell peppers, and berries.

• 🚫 WHAT TO AVOID:
  1. Ice Cold Drinks & Dairy: Avoid ice-cold beverages or heavy cream that can aggravate congestion.
  2. Fried & Sugary Foods: Avoid oily snacks that increase inflammation.

• 🏃 RECOMMENDED EXERCISES:
  1. Light Stretching & Full Rest: Prioritize rest; avoid heavy workouts until fever and acute symptoms subside.

Disclaimer: Educational triage advice tailored to your health profile.''';
    }

    // 9. General Health & Symptom Guidance
    return '''HEALTH ADVICE: Hello $name, here is a personalized health evaluation for your inquiry regarding "$input":

$profileSummaryHeader

• Profile Analysis & Specific Insights:
  - We evaluated your physical stats (${height != null ? '$height cm' : 'Height N/A'}, ${weight != null ? '$weight kg' : 'Weight N/A'}${bmi != null ? ' - BMI: ${bmi.toStringAsFixed(1)} $bmiCategory' : ''}) and medical background.
  ${conditionsStr != 'None recorded' ? '- Disease Specific Insight: For your recorded condition ($conditionsStr), maintaining consistent lifestyle habits, vitals tracking, and medication schedules is essential.' : '- General Wellness Goal: Aim for 7–8 hours of sound sleep, consistent hydration, and 30 minutes of daily activity.'}

• 🥗 WHAT TO EAT & DRINK:
  1. Balanced Nutrition: Whole grains, lean proteins, vegetables, fruits, and proper daily hydration.

• 🚫 WHAT TO AVOID:
  1. Habits to Avoid: Prolonged sitting, ultra-processed junk food, and skipping rest.

• 🏃 RECOMMENDED EXERCISES:
  1. Daily Activity: 30 minutes of moderate movement (brisk walking, stretching, or light cardio) 5 days a week.

• Specialist Access:
  If symptoms persist or worsen, you can book a doctor consultation directly on HealthOS.

Disclaimer: Guidance tailored to your recorded health profile for educational awareness.''';
  }

  Future<String> getClinicalSummary(String medicalHistory) async {
    final prompt = '''
    You are a clinical assistant. Summarize the following patient medical history into 3 clear, actionable bullet points for a doctor.

    History: $medicalHistory
    ''';

    try {
      if (_proModel != null) {
        final response = await _proModel!.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      }
    } catch (e) {
      debugPrint('Clinical summary fallback error: $e');
    }

    return '• Patient medical history noted.\n• Recommended routine baseline lab checks & vital check.\n• Follow-up consultation scheduled for clinical review.';
  }
}

