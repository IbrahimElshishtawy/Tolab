List<Map<String, dynamic>> students = [
  {
    "name": "Ahmed Ali",
    "student_id": "S001",
    "email": "ahmed.ali@university.edu",
    "gpa_current": 3.8,
    "gpa_previous_years": [3.5, 3.4],
    "subjects_grades": {
      "Math": 3.9,
      "Physics": 3.7,
      "Computer Science": 4.0,
      "AI Fundamentals": 3.8,
      "Machine Learning": 4.0,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 28,
      "attendance_percentage": 93.33,
    },
    "semester_grade": 3.8,
    "exam_number": "G12345",
    "status": "Active",
    "department": "Computer Science",
    "year": 1,
    "comments": [
      {"date": "2025-01-10", "content": "Good performance in AI fundamentals."},
      {"date": "2025-02-15", "content": "Needs to improve in Physics."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.9},
    ],
  },
  {
    "name": "Mona Salah",
    "student_id": "S002",
    "email": "mona.salah@university.edu",
    "gpa_current": 3.6,
    "gpa_previous_years": [3.3, 3.1],
    "subjects_grades": {
      "Math": 3.8,
      "Networking": 3.6,
      "Information Systems": 3.9,
      "Database Management": 3.7,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 27,
      "attendance_percentage": 90,
    },
    "semester_grade": 3.7,
    "exam_number": "G12346",
    "status": "Active",
    "department": "Information Systems",
    "year": 1,
    "comments": [
      {"date": "2025-01-12", "content": "Excellent performance in Networking."},
      {
        "date": "2025-02-20",
        "content": "Could use improvement in Database Management.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.7},
      {"year": 2, "gpa": 3.8},
    ],
  },
  {
    "name": "Ali Hassan",
    "student_id": "S003",
    "email": "ali.hassan@university.edu",
    "gpa_current": 3.9,
    "gpa_previous_years": [3.6, 3.4],
    "subjects_grades": {
      "Machine Learning": 4.0,
      "AI Ethics": 3.8,
      "Python Programming": 3.9,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 30,
      "attendance_percentage": 100,
    },
    "semester_grade": 4.0,
    "exam_number": "G22345",
    "status": "Active",
    "department": "AI",
    "year": 2,
    "comments": [
      {"date": "2025-01-10", "content": "Excellent work in Machine Learning."},
      {
        "date": "2025-02-15",
        "content": "AI Ethics needs more practical examples.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Sarah Mohamed",
    "student_id": "S004",
    "email": "sarah.mohamed@university.edu",
    "gpa_current": 3.7,
    "gpa_previous_years": [3.5, 3.4],
    "subjects_grades": {
      "Math": 3.8,
      "Digital Systems": 3.7,
      "Computer Networks": 3.9,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 25,
      "attendance_percentage": 83.33,
    },
    "semester_grade": 3.7,
    "exam_number": "G22346",
    "status": "Active",
    "department": "Computer Science",
    "year": 2,
    "comments": [
      {"date": "2025-01-12", "content": "Great effort in Digital Systems."},
      {"date": "2025-02-20", "content": "Needs to improve attendance."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.7},
    ],
  },
  {
    "name": "Youssef Khaled",
    "student_id": "S005",
    "email": "youssef.khaled@university.edu",
    "gpa_current": 3.8,
    "gpa_previous_years": [3.5, 3.3],
    "subjects_grades": {
      "Database Systems": 3.9,
      "Software Engineering": 3.8,
      "AI Fundamentals": 4.0,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 30,
      "attendance_percentage": 100,
    },
    "semester_grade": 3.9,
    "exam_number": "G12347",
    "status": "Active",
    "department": "AI",
    "year": 2,
    "comments": [
      {"date": "2025-01-15", "content": "AI Fundamentals is strong."},
      {
        "date": "2025-02-18",
        "content": "Could enhance Software Engineering knowledge.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 3.8},
    ],
  },
  // Adding 5 more students for IT department and other years
  {
    "name": "Omar Farouk",
    "student_id": "S006",
    "email": "omar.farouk@university.edu",
    "gpa_current": 3.7,
    "gpa_previous_years": [3.5, 3.2],
    "subjects_grades": {
      "Programming": 3.8,
      "Data Structures": 3.6,
      "Software Engineering": 3.9,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 27,
      "attendance_percentage": 90,
    },
    "semester_grade": 3.7,
    "exam_number": "G22347",
    "status": "Active",
    "department": "IT",
    "year": 3,
    "comments": [
      {
        "date": "2025-01-20",
        "content": "Good understanding of Data Structures.",
      },
      {"date": "2025-02-22", "content": "Needs more participation in class."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.7},
    ],
  },
  {
    "name": "Tariq Salah",
    "student_id": "S007",
    "email": "tariq.salah@university.edu",
    "gpa_current": 3.5,
    "gpa_previous_years": [3.2, 3.0],
    "subjects_grades": {"Math": 3.6, "Physics": 3.4, "Computer Networks": 3.7},
    "attendance": {
      "total_classes": 30,
      "classes_attended": 26,
      "attendance_percentage": 86.67,
    },
    "semester_grade": 3.5,
    "exam_number": "G22348",
    "status": "Active",
    "department": "IT",
    "year": 3,
    "comments": [
      {"date": "2025-01-25", "content": "Needs improvement in Physics."},
      {
        "date": "2025-02-10",
        "content": "Good performance in Computer Networks.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.7},
      {"year": 2, "gpa": 3.6},
    ],
  },
  {
    "name": "Fatma El-Hady",
    "student_id": "S008",
    "email": "fatma.elhady@university.edu",
    "gpa_current": 3.9,
    "gpa_previous_years": [3.8, 3.6],
    "subjects_grades": {
      "AI Ethics": 4.0,
      "Machine Learning": 3.9,
      "Data Structures": 3.8,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 30,
      "attendance_percentage": 100,
    },
    "semester_grade": 3.9,
    "exam_number": "G22349",
    "status": "Active",
    "department": "AI",
    "year": 4,
    "comments": [
      {"date": "2025-02-01", "content": "Excellent work in Machine Learning."},
      {"date": "2025-02-18", "content": "Great in AI Ethics."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Ayman Gamal",
    "student_id": "S009",
    "email": "ayman.gamal@university.edu",
    "gpa_current": 3.7,
    "gpa_previous_years": [3.5, 3.3],
    "subjects_grades": {
      "Mathematics": 3.8,
      "Software Engineering": 3.6,
      "AI Fundamentals": 3.9,
    },
    "attendance": {
      "total_classes": 30,
      "classes_attended": 28,
      "attendance_percentage": 93.33,
    },
    "semester_grade": 3.7,
    "exam_number": "G22350",
    "status": "Active",
    "department": "IT",
    "year": 4,
    "comments": [
      {"date": "2025-02-05", "content": "Improving in Software Engineering."},
      {
        "date": "2025-02-25",
        "content": "AI Fundamentals needs some more review.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.7},
      {"year": 2, "gpa": 3.8},
    ],
  },
];

//-----------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------
List<Map<String, dynamic>> assistants = [
  {
    "name": "Mohamed Ahmed",
    "assistant_id": "A001",
    "email": "mohamed.ahmed@university.edu",
    "department": "AI",
    "assigned_courses": ["Machine Learning", "AI Ethics"],
    "attendance": {
      "total_classes": 20,
      "classes_attended": 18,
      "attendance_percentage": 90,
    },
    "semester_grade": 4.0,
    "status": "Active",
    "comments": [
      {"date": "2025-01-10", "content": "Good progress in AI course material."},
      {"date": "2025-02-20", "content": "Needs more engagement with students."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Nour Hossam",
    "assistant_id": "A002",
    "email": "nour.hossam@university.edu",
    "department": "AI",
    "assigned_courses": ["Python Programming", "Deep Learning"],
    "attendance": {
      "total_classes": 20,
      "classes_attended": 19,
      "attendance_percentage": 95,
    },
    "semester_grade": 3.9,
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-15",
        "content": "Excellent teaching in Python Programming.",
      },
      {
        "date": "2025-02-18",
        "content": "Deep Learning course needs clearer examples.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.9},
    ],
  },
  {
    "name": "Amal El-Sayed",
    "assistant_id": "A003",
    "email": "amal.elsayed@university.edu",
    "department": "AI",
    "assigned_courses": ["Natural Language Processing", "AI Ethics"],
    "attendance": {
      "total_classes": 20,
      "classes_attended": 20,
      "attendance_percentage": 100,
    },
    "semester_grade": 4.0,
    "status": "Active",
    "comments": [
      {"date": "2025-01-18", "content": "Outstanding performance in NLP."},
      {"date": "2025-02-22", "content": "Ethics in AI needs more interaction."},
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.7},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Rania Hussein",
    "assistant_id": "A004",
    "email": "rania.hussein@university.edu",
    "department": "Computer Science",
    "assigned_courses": ["Data Structures", "Algorithms"],
    "attendance": {
      "total_classes": 20,
      "classes_attended": 15,
      "attendance_percentage": 75,
    },
    "semester_grade": 3.8,
    "status": "Active",
    "comments": [
      {
        "date": "2025-02-05",
        "content": "Needs improvement in Data Structures.",
      },
      {
        "date": "2025-02-25",
        "content": "Excellent problem-solving in Algorithms.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.5},
      {"year": 2, "gpa": 3.8},
    ],
  },
  {
    "name": "Ahmed Magdy",
    "assistant_id": "A005",
    "email": "ahmed.magdy@university.edu",
    "department": "Computer Science",
    "assigned_courses": ["Database Systems", "Software Engineering"],
    "attendance": {
      "total_classes": 20,
      "classes_attended": 20,
      "attendance_percentage": 100,
    },
    "semester_grade": 4.0,
    "status": "Active",
    "comments": [
      {"date": "2025-02-10", "content": "Good grasp of Database Systems."},
      {
        "date": "2025-02-28",
        "content": "Needs more interactive exercises in Software Engineering.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
];

//---------------------------------------------------------------------------------------------------
List<Map<String, dynamic>> professors = [
  {
    "name": "Dr. Hossam Fathi",
    "professor_id": "P001",
    "email": "dr.hossam.fathi@university.edu",
    "department": "AI",
    "teaching_courses": ["AI Fundamentals", "AI Ethics"],
    "semester_grade": 4.0,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 24,
      "attendance_percentage": 96,
    },
    "status": "Active",
    "comments": [
      {"date": "2025-01-05", "content": "Great depth of knowledge in AI."},
      {
        "date": "2025-02-10",
        "content": "Needs to improve the pacing of lectures.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 4.0},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Dr. Mona Fathy",
    "professor_id": "P002",
    "email": "dr.mona.fathy@university.edu",
    "department": "Computer Science",
    "teaching_courses": ["Algorithms", "Data Structures"],
    "semester_grade": 3.8,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 23,
      "attendance_percentage": 92,
    },
    "status": "Active",
    "comments": [
      {"date": "2025-01-10", "content": "Great teaching in Algorithms."},
      {
        "date": "2025-02-18",
        "content": "Could use more examples in Data Structures.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.9},
    ],
  },
  {
    "name": "Dr. Amr Helmy",
    "professor_id": "P003",
    "email": "dr.amr.helmy@university.edu",
    "department": "Information Systems",
    "teaching_courses": ["Database Management", "Software Architecture"],
    "semester_grade": 3.9,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 24,
      "attendance_percentage": 96,
    },
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-12",
        "content": "Excellent in explaining Database Management concepts.",
      },
      {
        "date": "2025-02-15",
        "content":
            "Software Architecture class needs clearer real-life examples.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Dr. Ziad Fathi",
    "professor_id": "P004",
    "email": "dr.ziad.fathi@university.edu",
    "department": "IT",
    "teaching_courses": ["Network Security", "Cybersecurity"],
    "semester_grade": 4.0,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 25,
      "attendance_percentage": 100,
    },
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-10",
        "content": "Great insights into Network Security.",
      },
      {
        "date": "2025-02-20",
        "content": "Cybersecurity could use more practical workshops.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Dr. Amira Khaled",
    "professor_id": "P005",
    "email": "dr.amira.khaled@university.edu",
    "department": "Computer Science",
    "teaching_courses": ["Data Science", "Machine Learning"],
    "semester_grade": 3.8,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 22,
      "attendance_percentage": 88,
    },
    "status": "Active",
    "comments": [
      {"date": "2025-01-15", "content": "Good in Data Science lectures."},
      {
        "date": "2025-02-25",
        "content": "Machine Learning class could use more coding examples.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.9},
    ],
  },
  {
    "name": "Dr. Khaled Abdelaziz",
    "professor_id": "P006",
    "email": "dr.khaled.abdelaziz@university.edu",
    "department": "AI",
    "teaching_courses": ["Artificial Intelligence", "Robotics"],
    "semester_grade": 4.0,
    "attendance": {
      "total_classes": 25,
      "classes_attended": 25,
      "attendance_percentage": 100,
    },
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-07",
        "content": "Very knowledgeable in Artificial Intelligence.",
      },
      {
        "date": "2025-02-10",
        "content": "Robotics course needs more hands-on projects.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 4.0},
      {"year": 2, "gpa": 4.0},
    ],
  },
];

//---------------------------------------------------------------------------------------------------
List<Map<String, dynamic>> itSpecialists = [
  {
    "name": "Mohamed Aziz",
    "id": "IT001",
    "role": "IT Specialist",
    "department": "IT",
    "email": "mohamed.aziz@university.edu",
    "assigned_tasks": ["Network Management", "Database Administration"],
    "attendance": {
      "total_classes": 25,
      "classes_attended": 25,
      "attendance_percentage": 100,
    },
    "semester_grade": 4.0,
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-07",
        "content": "Excellent work in network management.",
      },
      {
        "date": "2025-02-12",
        "content": "Completed database administration tasks effectively.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Amira Ahmed",
    "id": "IT002",
    "role": "IT Support Specialist",
    "department": "IT",
    "email": "amira.ahmed@university.edu",
    "assigned_tasks": ["Server Maintenance", "Software Installation"],
    "attendance": {
      "total_classes": 25,
      "classes_attended": 23,
      "attendance_percentage": 92,
    },
    "semester_grade": 3.9,
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-10",
        "content": "Efficient in server maintenance tasks.",
      },
      {
        "date": "2025-02-18",
        "content":
            "Needs more improvement in software installation procedures.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.9},
    ],
  },
  {
    "name": "Youssef Khaled",
    "id": "IT003",
    "role": "IT Security Specialist",
    "department": "IT",
    "email": "youssef.khaled@university.edu",
    "assigned_tasks": ["Cybersecurity", "Risk Assessment"],
    "attendance": {
      "total_classes": 25,
      "classes_attended": 24,
      "attendance_percentage": 96,
    },
    "semester_grade": 4.0,
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-05",
        "content": "Strong understanding of cybersecurity concepts.",
      },
      {
        "date": "2025-02-10",
        "content": "Could use more in-depth analysis in risk assessment tasks.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.9},
      {"year": 2, "gpa": 4.0},
    ],
  },
  {
    "name": "Sara Tarek",
    "id": "IT004",
    "role": "Database Administrator",
    "department": "IT",
    "email": "sara.tarek@university.edu",
    "assigned_tasks": ["Database Optimization", "Backup Management"],
    "attendance": {
      "total_classes": 25,
      "classes_attended": 22,
      "attendance_percentage": 88,
    },
    "semester_grade": 3.8,
    "status": "Active",
    "comments": [
      {
        "date": "2025-01-14",
        "content": "Excellent work in database optimization.",
      },
      {
        "date": "2025-02-20",
        "content": "Backup management procedures need more attention.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.7},
      {"year": 2, "gpa": 3.8},
    ],
  },
  {
    "name": "Omar Farouk",
    "id": "IT005",
    "role": "Network Specialist",
    "department": "IT",
    "email": "omar.farouk@university.edu",
    "assigned_tasks": ["Network Troubleshooting", "Infrastructure Design"],
    "attendance": {
      "total_classes": 25,
      "classes_attended": 20,
      "attendance_percentage": 80,
    },
    "semester_grade": 3.7,
    "status": "Active",
    "comments": [
      {"date": "2025-01-12", "content": "Great troubleshooting skills."},
      {
        "date": "2025-02-15",
        "content": "Could improve in infrastructure design tasks.",
      },
    ],
    "academic_history": [
      {"year": 1, "gpa": 3.8},
      {"year": 2, "gpa": 3.7},
    ],
  },
];
List<Map<String, dynamic>> admins = [
  {
    "email": "admin@tolab.com",
    "password": "123456",
    "name": "Super Admin",
    "role": "Administrator",
  },
  {
    "email": "manager@tolab.com",
    "password": "manager123",
    "name": "IT Manager",
    "role": "Manager",
  },
];
