class TransactionCategorizer {
  static final Map<String, String> keywordToCategory = {
    'Savings Vault topup': 'Savings',
    'To ': 'Transfer',
    'Exchanged to EUR': 'Currency Exchange',
    'Coca-Cola': 'Food & Drinks',
    'ALDI': 'Groceries',
    'Sult NUI Gallway': 'Education',
    'ASOS': 'Shopping',
    'Amazon': 'Shopping',
    'Truffle': 'Food & Drinks',
    'Eir': 'Utilities',
    'An Post': 'Postal Services',
    'The Lane Cafe': 'Food & Drinks',
    'Coinbase Ireland Limited': 'Investments',
    'Holland & Barrett': 'Health & Wellness',
    'FREE NOW': 'Transportation',
    'Galway Bay Hotel': 'Travel',
    'Centra': 'Groceries',
    'Supermac\'s': 'Food & Drinks',
    'The Residence Hotel': 'Travel',
    'NUIG Students\' Union Shop': 'Education',
    'Feel Good Contacts': 'Health & Wellness',
    'Deliveroo': 'Food & Drinks',
    'Starbucks': 'Food & Drinks',
    'Dunnes Stores': 'Groceries',
    'Penneys': 'Shopping',
    'Electricity Bill': 'Utilities',
    'Gas Bill': 'Utilities',
    'Water Bill': 'Utilities',
    'Netflix': 'Entertainment',
    'Gym Membership': 'Health & Wellness',
    'Uber': 'Transportation',
    'Airbnb': 'Travel',
    'Flight Ticket': 'Travel',
    'Car Rental': 'Transportation',
    'Petrol': 'Transportation',
    'Restaurant': 'Food & Drinks',
    'Takeaway': 'Food & Drinks',
    'Pharmacy': 'Health & Wellness',
    'Hospital': 'Healthcare',
    'Insurance': 'Financial Services',
    'Loan Payment': 'Financial Services',
    'Interest Payment': 'Financial Services',
    'Salary Deposit': 'Income',
    'Wages': 'Income',
    'Tuition Fee': 'Education',
    'Living Expenses': 'Expenses',
    'Rent Payment': 'Expenses',
    'Internet Bill': 'Utilities',
    'Mobile Phone Bill': 'Utilities',
    'Cable TV Bill': 'Utilities',
    'Online Subscription': 'Entertainment',
    'Gym Fee': 'Health & Wellness',
    'Transportation Fee': 'Transportation',
    'Car Maintenance': 'Transportation',
    'Public Transport': 'Transportation',
    'Parking Fee': 'Transportation',
    'Medical Bill': 'Healthcare',
    'Dental Bill': 'Healthcare',
    'Prescription': 'Healthcare',
    'Tax Payment': 'Financial Services',
    'Investment Withdrawal': 'Investments',
    'Charity Donation': 'Charity',
    'Credit Card Payment': 'Financial Services',
    'Bank Fee': 'Financial Services',
    'ATM Withdrawal': 'Cash',
    'Cash Deposit': 'Cash',
    'Dividend Payment': 'Investments',
    'Stock Purchase': 'Investments',
    'Bitcoin Purchase': 'Cryptocurrency',
    'Clas Ohlson': 'Retail',
    'Boots': 'Health & Wellness',
    'HMSHost International': 'Food & Drinks',
    'Nut Hot Chinese Takeaway': 'Food & Drinks',
    'Carroll\'s Bar': 'Food & Drinks',
  };
}