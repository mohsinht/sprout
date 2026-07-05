import type { LearnResponse } from "./learn.js";

export const mockLearnResponse: LearnResponse = {
  user: {
    level: 6,
    xp: 1840,
    dayStreak: 12
  },
  path: {
    id: "money-basics-pk",
    title: {
      en: "Money Basics",
      ur: "پیسے کی بنیادی باتیں"
    },
    levelLabel: "Level 3",
    nodes: [
      {
        id: "ibft",
        title: {
          en: "What is IBFT",
          ur: "آئی بی ایف ٹی کیا ہے"
        },
        status: "available",
        xp: 20
      },
      {
        id: "raast-vs-card",
        title: {
          en: "Raast vs card",
          ur: "راست یا کارڈ"
        },
        status: "locked",
        xp: 25
      },
      {
        id: "salary-tax-basics",
        title: {
          en: "Salary tax basics",
          ur: "تنخواہ ٹیکس کی بنیاد"
        },
        status: "locked",
        xp: 25
      },
      {
        id: "inflation-savings",
        title: {
          en: "Inflation ate your savings",
          ur: "مہنگائی اور بچت"
        },
        status: "locked",
        xp: 30
      }
    ],
    lessons: [
      {
        id: "ibft",
        cards: [
          {
            title: {
              en: "IBFT moves money between banks",
              ur: "آئی بی ایف ٹی بینکوں کے درمیان رقم بھیجتا ہے"
            },
            body: {
              en: "In Pakistan, IBFT is the everyday bank-to-bank transfer you use from Meezan, HBL, UBL, JazzCash, Easypaisa, and other apps.",
              ur: "پاکستان میں آئی بی ایف ٹی روزمرہ بینک ٹرانسفر کے لیے استعمال ہوتا ہے۔"
            }
          },
          {
            title: {
              en: "Check the name before sending",
              ur: "بھیجنے سے پہلے نام دیکھیں"
            },
            body: {
              en: "The safest habit is tiny: confirm the receiver name, amount, and fee before you tap send.",
              ur: "محفوظ عادت یہ ہے کہ بھیجنے سے پہلے نام، رقم، اور فیس چیک کریں۔"
            }
          }
        ],
        checkQuestion: {
          prompt: {
            en: "Before an IBFT, what should you confirm?",
            ur: "آئی بی ایف ٹی سے پہلے کیا چیک کرنا چاہیے؟"
          },
          options: [
            {
              en: "Receiver name, amount, and fee",
              ur: "وصول کنندہ کا نام، رقم، اور فیس"
            },
            {
              en: "Only your account balance",
              ur: "صرف اپنا اکاؤنٹ بیلنس"
            },
            {
              en: "The chai category",
              ur: "چائے کی کیٹیگری"
            }
          ],
          correctIndex: 0,
          explanation: {
            en: "Exactly. A quick name, amount, and fee check prevents most transfer mistakes.",
            ur: "بالکل۔ نام، رقم، اور فیس چیک کرنے سے اکثر غلطیاں رک جاتی ہیں۔"
          }
        }
      },
      {
        id: "raast-vs-card",
        cards: [
          {
            title: {
              en: "Raast is built for instant transfers",
              ur: "راست فوری ٹرانسفر کے لیے ہے"
            },
            body: {
              en: "Raast often works well for quick person-to-person payments without sharing long account numbers.",
              ur: "راست لمبے اکاؤنٹ نمبر کے بغیر فوری ادائیگی میں مدد دیتا ہے۔"
            }
          },
          {
            title: {
              en: "Cards are better for merchant records",
              ur: "کارڈ مرچنٹ ریکارڈ کے لیے بہتر ہیں"
            },
            body: {
              en: "For groceries, fuel, and subscriptions, cards can leave a cleaner receipt trail for your budget.",
              ur: "گروسری، فیول، اور سبسکرپشنز کے لیے کارڈ بجٹ ریکارڈ صاف رکھتا ہے۔"
            }
          }
        ],
        checkQuestion: {
          prompt: {
            en: "Which choice usually gives a cleaner spending record?",
            ur: "خرچ کا صاف ریکارڈ عموماً کس سے ملتا ہے؟"
          },
          options: [
            {
              en: "Card payment at the merchant",
              ur: "مرچنٹ پر کارڈ ادائیگی"
            },
            {
              en: "Cash with no note",
              ur: "بغیر نوٹ کے کیش"
            }
          ],
          correctIndex: 0,
          explanation: {
            en: "Nice. Cards can make later review easier because the merchant name is usually captured.",
            ur: "درست۔ کارڈ سے بعد میں جائزہ آسان ہوتا ہے کیونکہ مرچنٹ کا نام آ جاتا ہے۔"
          }
        }
      },
      {
        id: "salary-tax-basics",
        cards: [
          {
            title: {
              en: "Gross and net salary are different",
              ur: "گراس اور نیٹ تنخواہ مختلف ہیں"
            },
            body: {
              en: "Gross salary is before deductions. Net salary is what lands in your account after tax, provident fund, and other deductions.",
              ur: "گراس تنخواہ کٹوتیوں سے پہلے، نیٹ تنخواہ کٹوتیوں کے بعد اکاؤنٹ میں آتی ہے۔"
            }
          },
          {
            title: {
              en: "Plan from net salary",
              ur: "نیٹ تنخواہ سے پلان بنائیں"
            },
            body: {
              en: "Your monthly budget should use the amount that actually arrives in your Meezan or salary account.",
              ur: "ماہانہ بجٹ اسی رقم پر بنائیں جو واقعی اکاؤنٹ میں آتی ہے۔"
            }
          }
        ],
        checkQuestion: {
          prompt: {
            en: "Which salary number should drive your monthly budget?",
            ur: "ماہانہ بجٹ کس تنخواہ نمبر سے بننا چاہیے؟"
          },
          options: [
            {
              en: "Net salary",
              ur: "نیٹ تنخواہ"
            },
            {
              en: "Gross salary",
              ur: "گراس تنخواہ"
            }
          ],
          correctIndex: 0,
          explanation: {
            en: "Correct. Net salary is the money you can actually assign to bills, committee, Zakat, and savings.",
            ur: "درست۔ نیٹ تنخواہ وہ رقم ہے جو بل، کمیٹی، زکات، اور بچت میں لگ سکتی ہے۔"
          }
        }
      },
      {
        id: "inflation-savings",
        cards: [
          {
            title: {
              en: "Inflation shrinks idle cash",
              ur: "مہنگائی خالی پڑی رقم کو کمزور کرتی ہے"
            },
            body: {
              en: "If prices rise faster than your cash grows, the same PKR buys less chai, fuel, and groceries later.",
              ur: "اگر قیمتیں رقم سے تیزی سے بڑھیں تو بعد میں وہی روپے کم چیزیں خریدتے ہیں۔"
            }
          },
          {
            title: {
              en: "Match money to timing",
              ur: "رقم کو وقت کے حساب سے رکھیں"
            },
            body: {
              en: "Keep near-term bills in cash. Longer-term goals can sit in safer growth buckets like a money market fund after you understand the risk.",
              ur: "قریبی بل کیش میں رکھیں۔ لمبے مقصد محفوظ گروتھ بکٹ میں جا سکتے ہیں۔"
            }
          }
        ],
        checkQuestion: {
          prompt: {
            en: "What does inflation do to cash that sits idle?",
            ur: "مہنگائی خالی پڑی کیش کے ساتھ کیا کرتی ہے؟"
          },
          options: [
            {
              en: "It can reduce buying power",
              ur: "خریدنے کی طاقت کم کر سکتی ہے"
            },
            {
              en: "It guarantees profit",
              ur: "منافع کی گارنٹی دیتی ہے"
            }
          ],
          correctIndex: 0,
          explanation: {
            en: "Yes. Inflation is not a reason to rush, but it is a reason to plan calmly.",
            ur: "جی۔ مہنگائی جلد بازی کی وجہ نہیں، سکون سے پلان کرنے کی وجہ ہے۔"
          }
        }
      }
    ]
  }
};
