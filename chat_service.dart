import 'dart:math';

class ChatService {
  final Map<String, List<String>> _replyPatterns = {

    'tired|exhausted|fatigue|sleepy': [
      "You've done enough for today. It's okay to rest. 😌",
      "A short walk or gentle stretch might recharge your energy. 🚶‍♂️",
      "Fatigue is your body asking for care. Listen to it. 🛌",
      "Consider a 20-minute power nap if possible. Your body will thank you. ⏳",
      "Even superheroes need rest. You're no different. 🦸‍♂️",
    ],
    'sad|depressed|down|low|blue': [
      "It's okay to feel down. You're not alone. ❤️",
      "Try writing in your journal or taking a quiet moment. 📝",
      "Bad days happen. Tomorrow is a clean slate. 🌅",
      "This feeling won't last forever. Hold on. 🌈",
      "Would you like to talk about what's bothering you? 👂",
    ],

    'stress|anxious|pressure|overwhelm': [
      "Deep breaths. Inhale for 4, hold for 4, exhale for 6. 🌬️",
      "Try the 5-4-3-2-1 grounding technique: Name 5 things you see, 4 you feel... 🧠",
      "You are stronger than you feel right now. 💪",
      "This moment will pass. Just breathe through it. 🌊",
      "Write down what's stressing you, then tear it up. Symbolic release. ✂️",
    ],

    'water|hydrate|thirsty': [
      "Stay hydrated! Your brain works 14% better when properly hydrated. 💧",
      "Your body loves water. Go ahead, drink some. 🚰",
      "Water now. Motivation later. 😉",
      "Dehydration can mimic hunger. Have you had enough water today? 🥤",
      "Try adding lemon or cucumber to make water more appealing. 🍋",
    ],

    'calories|diet|food|eat|nutrition': [
      "Your food choices shape your energy. Proud of you for tracking. �",
      "Don't stress about perfection. Balance is key. 🥗",
      "You're doing great. One meal at a time. 🧠",
      "Remember: Food is fuel, not just numbers. 🚀",
      "What's one nutritious food you enjoy that makes you feel good? 🍓",
    ],

    'exercise|workout|move|active|steps': [
      "Did you get movement today? Even 5 minutes helps. 🏃‍♀️",
      "Your body craves motion. A little stretch could be perfect. 🧘‍♀️",
      "You don't need a full workout—just start small. 🔁",
      "Exercise is a celebration of what your body can do! 🎉",
      "Try 'exercise snacks'—short bursts of activity throughout the day. 🍬",
    ],

    'lonely|isolated|alone': [
      "I'm here for you. It's okay to feel this way sometimes. 🤗",
      "Reach out to someone if you can. Or just sit with yourself gently. 💙",
      "Being alone doesn't mean you're not loved. ❤️",
      "Virtual connections count too. Maybe message an old friend? 📱",
      "Community is important. What groups or activities might help you connect? 👥",
    ],

    'happy|joy|excited|good|great': [
      "I'm glad you're feeling good! Celebrate the small wins! 🎉",
      "That's wonderful to hear. Keep spreading that joy! 🌟",
      "Happiness looks good on you. 😊",
      "Savor this moment—what makes it special? 🌸",
      "Positive emotions are worth noticing too. Thanks for sharing! ✨",
    ],

    'sleep|insomnia|awake|tired': [
      "Sleep is foundational health. Try a bedtime routine if you can. 🌙",
      "Screen-free time before bed helps your brain wind down. 📵",
      "Even resting with eyes closed has benefits. Don't stress about sleeping. 😴",
      "Your sleep environment matters—cool, dark, and quiet is ideal. 🛏️",
      "Deep breathing can help transition to sleep. Try 4-7-8 breathing. 🌬️",
    ],

    'motivation|procrastinate|lazy|stuck': [
      "Action often comes before motivation, not the other way around. 🚶‍♂️",
      "What's the smallest step you could take right now? 🪜",
      "Progress, not perfection. What's one thing you could do? 🎯",
      "Sometimes starting is the hardest part. Set a timer for just 5 minutes. ⏱️",
      "Your future self will thank you for beginning today. 💌",
    ],
  };

  final List<String> _genericReplies = [
    "Tell me more about how you're feeling. I'm listening. 👂",
    "I'm here whenever you want to chat. 🤖",
    "Every day is a chance to start again. 💫",
    "Remember to be kind to yourself. You're doing better than you think. 💛",
    "Your journey matters. Keep going. 🌈",
    "Take a break if you need to. You're allowed to rest. 🌿",
    "You are important. Your health—both body and mind—is a priority. 🧘‍♂️",
    "What's one small thing you're grateful for today? 😊",
    "Let's set a tiny goal for right now. What feels manageable? 🚶‍♀️",
    "Even talking to yourself kindly is progress. 💬",
    "How can I best support you right now? 💭",
    "Sometimes naming our feelings helps. What word comes closest? 🔤",
    "You're showing up for yourself by reaching out. That matters. 👏",
  ];

  final Map<String, String> _followUpQuestions = {
    'tired': "Have you been getting enough sleep lately?",
    'sad': "Is there something specific that's been on your mind?",
    'stress': "Would it help to brainstorm some solutions together?",
    'water': "Could you keep a water bottle nearby as a visual reminder?",
    'exercise': "What's one type of movement you actually enjoy?",
    'lonely': "Who's someone you haven't connected with in a while?",
    'happy': "Can you think of what contributed to this good feeling?",
    'sleep': "How could you make your bedtime routine more relaxing?",
  };

  Future<String> getReply(String prompt) async {
    await Future.delayed(Duration(milliseconds: 700 + (Random().nextInt(700))));

    final lowerPrompt = prompt.toLowerCase();
    String? matchedCategory;

    for (final pattern in _replyPatterns.keys) {
      if (RegExp(pattern).hasMatch(lowerPrompt)) {
        matchedCategory = pattern.split('|').first;
        break;
      }
    }

    if (matchedCategory != null) {
      final replies = _replyPatterns[matchedCategory]!;
      replies.shuffle();
      
      if (Random().nextDouble() < 0.3 && _followUpQuestions.containsKey(matchedCategory)) {
        return "${replies.first}\n\n${_followUpQuestions[matchedCategory]}";
      }
      return replies.first;
    }

    _genericReplies.shuffle();
    return _genericReplies.first;
  }

  String getDailyMotivation() {
    final quotes = [
      "Small steps still move you forward. 🚶‍♂️",
      "You don't have to see the whole staircase, just take the first step. 🪜",
      "Progress is rarely linear. Be patient with yourself. 📈",
      "Self-care isn't selfish—it's necessary. 🛁",
      "You've survived 100% of your bad days so far. 💯",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }
}