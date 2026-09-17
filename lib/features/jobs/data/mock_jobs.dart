import '../models/job.dart';

/// The job board.
///
/// Real Canadian employers, salaries in Canadian dollars, and an NOC code on
/// every posting — because the NOC is what an immigration program matches on,
/// and a job board for newcomers that hides it is not doing its job.
const List<Job> mockJobs = [
  Job(
    id: 'j1',
    title: 'Senior Product Designer',
    company: 'Shopify',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 105000,
    salaryHigh: 135000,
    category: 'Design',
    postedHoursAgo: 52,
    searchCount: 2330,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Own end-to-end design for merchant-facing checkout, working with '
        'a squad of engineers and a researcher.',
    description: [
      'Shopify\'s checkout is where millions of merchants get paid, and '
          'small design decisions here move real revenue. You will join the '
          'Checkout squad as its senior designer, working alongside six '
          'engineers, a product manager and a user researcher.',
      'You will own problems from the first conversation with merchants to '
          'the release, and you will be trusted to decide what to build as much '
          'as how it looks. The team ships every week, so you will see your '
          'work in the hands of merchants quickly.',
    ],
    duties: [
      'Lead design for checkout from first sketch to shipped feature',
      'Plan and run usability sessions with merchants',
      'Build interactive prototypes to test ideas before they are built',
      'Review designs across the squad and raise the quality bar',
      'Work with engineers during build so the shipped result matches',
    ],
    experience: 'Five years or more designing digital products, with a '
        'portfolio of shipped work',
    education: "Bachelor's degree in design or a related field, or equivalent "
        'experience',
    certifications: [],
    skills: [
      'Figma',
      'Prototyping',
      'User research',
      'Interaction design',
      'Design systems',
    ],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.bonus,
      JobBenefit.travelExpenses,
    },
    immigrationSupport: {ImmigrationSupport.lmia, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j2',
    title: 'UX Designer',
    company: 'Wealthsimple',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 95000,
    salaryHigh: 120000,
    category: 'Design',
    postedHoursAgo: 96,
    searchCount: 2120,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Design money flows people actually trust, on a team that treats '
        'clarity as a feature.',
    description: [
      'Wealthsimple helps Canadians invest, save and file their taxes. As a '
          'UX Designer on the Money Movement team, you will design how people '
          'deposit, withdraw and transfer funds, the moments where trust '
          'matters most.',
      'You will work closely with product, engineering and compliance to '
          'make regulated flows feel simple without cutting corners. '
          'Accessibility is built into how the team works from the start.',
    ],
    duties: [
      'Design account, transfer and investing flows',
      'Map user journeys and find where people drop off',
      'Check every design against accessibility standards',
      'Present design decisions to product and compliance teams',
    ],
    experience: 'Three years or more in product design, ideally on a '
        'regulated or financial product',
    education: "Bachelor's degree in design, HCI or a related field",
    certifications: [],
    skills: ['Figma', 'User journeys', 'Accessibility', 'UX writing'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j3',
    title: 'Product Designer',
    company: 'Hootsuite',
    location: 'Vancouver, British Columbia',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 90000,
    salaryHigh: 115000,
    category: 'Design',
    postedHoursAgo: 168,
    searchCount: 1760,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Shape the publishing experience used by social teams in 175 '
        'countries.',
    description: [
      'Hootsuite helps social media teams plan, publish and measure their '
          'work. You will join the Publishing team, designing the tools '
          'customers use every day to schedule and approve posts.',
      'The team values fast learning: you will test rough concepts with '
          'customers early, then refine them into components that work across '
          'the whole product.',
    ],
    duties: [
      'Design publishing and scheduling features',
      'Build and extend shared components with the design system team',
      'Test concepts quickly with customers and iterate',
      'Write clear specifications for engineering handoff',
    ],
    experience: 'Three years or more designing software products',
    education: "Bachelor's degree or diploma in design or a related field",
    certifications: [],
    skills: ['Figma', 'Design systems', 'Rapid iteration', 'Usability testing'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.travelExpenses},
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j4',
    title: 'Design Systems Lead',
    company: 'Telus Digital',
    location: 'Calgary, Alberta',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 115000,
    salaryHigh: 145000,
    category: 'Design',
    postedHoursAgo: 72,
    searchCount: 1150,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Run the design system across a 60-person product organisation.',
    description: [
      'Telus Digital is growing its product organisation and needs one '
          'design system that 60 designers and engineers can rely on. As Design '
          'Systems Lead, you will set its direction and keep it healthy.',
      'You will lead a small team of designers and front-end engineers, '
          'write the guidance people actually use, and measure how well the '
          'system is adopted across products.',
    ],
    duties: [
      'Set the roadmap for the design system and its component library',
      'Write documentation and usage guidelines',
      'Work with front-end engineering to keep design and code in sync',
      'Coach designers on using and contributing to the system',
      'Measure adoption across product teams',
    ],
    experience: 'Seven years or more in design, including building or '
        'maintaining a production design system',
    education: "Bachelor's degree in design, computer science or a related "
        'field',
    certifications: [],
    skills: [
      'Design systems',
      'Design tokens',
      'Documentation',
      'Front-end collaboration',
      'Leadership',
    ],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.bonus,
      JobBenefit.travelExpenses,
    },
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j5',
    title: 'Content Designer',
    company: 'Benevity',
    location: 'Calgary, Alberta',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 80000,
    salaryHigh: 100000,
    category: 'Content',
    postedHoursAgo: 120,
    searchCount: 870,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Write the words that carry a giving platform used by two million '
        'people.',
    description: [
      'Benevity powers workplace giving and volunteering for some of the '
          'world\'s largest companies. As a Content Designer, you will shape '
          'the words people read when they donate, volunteer or apply for a '
          'grant.',
      'You will work inside product squads, own the content style guide, '
          'and test wording with real users to make sure every sentence earns '
          'its place.',
    ],
    duties: [
      'Write interface copy, error messages and onboarding',
      'Keep the content style guide current',
      'Test wording with users and act on the results',
      'Work with designers from the first sketch',
    ],
    experience: 'Three years or more in UX writing or content design',
    education: "Bachelor's degree in communications, English or a related "
        'field',
    certifications: [],
    skills: ['UX writing', 'Style guides', 'Plain language', 'Content testing'],
    benefits: {JobBenefit.healthInsurance},
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j6',
    title: 'UX Researcher',
    company: 'Clio',
    location: 'Burnaby, British Columbia',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 95000,
    salaryHigh: 118000,
    category: 'Design',
    postedHoursAgo: 144,
    searchCount: 990,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Run mixed-methods research for legal professionals who have very '
        'little time to give you.',
    description: [
      'Clio builds practice management software for lawyers. As a UX '
          'Researcher, you will help product teams understand busy legal '
          'professionals and turn what you learn into clear decisions.',
      'You will choose the right method for each question, from interviews '
          'to large surveys, and share your findings in a way that changes what '
          'the team builds next.',
    ],
    duties: [
      'Plan and run interviews, diary studies and surveys',
      'Analyse survey data and report what is statistically meaningful',
      'Turn findings into clear recommendations for product teams',
      'Maintain a shared library of research insights',
    ],
    experience: 'Four years or more in applied user research',
    education: "Master's degree in HCI, psychology or a related field "
        'preferred',
    certifications: [],
    skills: ['Interviewing', 'Survey design', 'Statistics', 'Synthesis'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j7',
    title: 'Front-End Developer',
    company: 'Jane App',
    location: 'North Vancouver, British Columbia',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 100000,
    salaryHigh: 130000,
    category: 'Programming',
    postedHoursAgo: 20,
    searchCount: 4100,
    permitFriendly: true,
    nocCode: '21232',
    summary: 'Build the booking experience used by clinics across North '
        'America.',
    description: [
      'Jane App helps clinics run their bookings, charting and billing. You '
          'will join the team that builds online booking, used by patients '
          'across North America to find and book appointments.',
      'You will write accessible, well-tested front-end code, improve '
          'performance on slow connections, and review code with a supportive '
          'team that pairs often.',
    ],
    duties: [
      'Build and maintain the online booking interface',
      'Write tested, accessible components',
      'Improve page load and runtime performance',
      'Review pull requests from other developers',
    ],
    experience: 'Four years or more building for the web',
    education: "Bachelor's degree or diploma in computer science, or "
        'equivalent experience',
    certifications: [],
    skills: ['JavaScript', 'TypeScript', 'React', 'Accessibility', 'Testing'],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.bonus,
      JobBenefit.travelExpenses,
    },
    immigrationSupport: {
      ImmigrationSupport.pnp,
      ImmigrationSupport.lmia,
      ImmigrationSupport.jobOffer,
    },
  ),
  Job(
    id: 'j8',
    title: 'Marketing Manager',
    company: 'Article',
    location: 'Vancouver, British Columbia',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 85000,
    salaryHigh: 105000,
    category: 'Marketing',
    postedHoursAgo: 168,
    searchCount: 1590,
    permitFriendly: false,
    nocCode: '10022',
    summary:
        'Own lifecycle marketing for a direct-to-consumer furniture brand.',
    description: [
      'Article sells modern furniture directly to customers across North '
          'America. As Marketing Manager, you will own lifecycle marketing, '
          'from a customer\'s first email to their repeat purchases.',
      'You will manage two specialists and a meaningful budget, and report '
          'on what each campaign adds to retention and revenue.',
    ],
    duties: [
      'Plan and run email and lifecycle campaigns',
      'Own the lifecycle marketing budget',
      'Report on campaign performance and customer retention',
      'Manage two marketing specialists',
    ],
    experience: 'Five years or more in growth or lifecycle marketing, '
        'including owning a budget',
    education: "Bachelor's degree in marketing, business or a related field",
    certifications: [],
    skills: ['Email marketing', 'Analytics', 'Segmentation', 'Budgeting'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {},
  ),
  Job(
    id: 'j9',
    title: 'Data Analyst',
    company: 'Loblaw Digital',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 85000,
    salaryHigh: 110000,
    category: 'Engineering',
    postedHoursAgo: 72,
    searchCount: 3420,
    permitFriendly: true,
    nocCode: '21223',
    summary:
        'Turn grocery e-commerce behaviour into decisions the merchandising '
        'team can act on.',
    description: [
      'Loblaw Digital runs online grocery for Canada\'s largest food '
          'retailer. As a Data Analyst, you will help the merchandising team '
          'understand what customers buy online and why.',
      'You will build dashboards the team relies on, analyse promotions, '
          'and explain your findings clearly to people who do not work with '
          'data every day.',
    ],
    duties: [
      'Write SQL to pull and clean e-commerce data',
      'Build and maintain dashboards for merchandising',
      'Analyse promotions and report what worked',
      'Present findings to non-technical teams',
    ],
    experience: 'Three years or more in data analytics',
    education: "Bachelor's degree in statistics, mathematics, computer science "
        'or a related field',
    certifications: [],
    skills: ['SQL', 'Python', 'Tableau', 'A/B testing', 'Data storytelling'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j10',
    title: 'Registered Nurse — Medical Unit',
    company: 'Alberta Health Services',
    location: 'Edmonton, Alberta',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 78000,
    salaryHigh: 102000,
    category: 'Healthcare',
    postedHoursAgo: 40,
    searchCount: 4820,
    permitFriendly: true,
    nocCode: '31301',
    summary: 'Medical inpatient unit, permanent full-time, rotating shifts.',
    description: [
      'Alberta Health Services is hiring a Registered Nurse for a busy '
          'medical inpatient unit at the University of Alberta Hospital in '
          'Edmonton. This is a permanent, full-time position on rotating day '
          'and night shifts.',
      'You will care for adults with complex medical conditions as part of '
          'a team of nurses, physicians and allied health professionals. '
          'Internationally educated nurses are welcome to apply, and support '
          'with registration is available.',
    ],
    duties: [
      'Assess patients and plan, deliver and evaluate their care',
      'Give medication and treatments as prescribed',
      'Monitor patients and respond to changes in their condition',
      'Teach patients and families about care after discharge',
      'Record care accurately in the electronic health record',
    ],
    experience: 'Two years or more of acute care nursing preferred',
    education: 'Nursing degree, with credentials assessed by NNAS if earned '
        'outside Canada',
    certifications: [
      'Registration with the College of Registered Nurses of Alberta',
      'Basic Life Support (BLS)',
    ],
    skills: [
      'Patient assessment',
      'Medication administration',
      'Charting',
      'Shift work',
    ],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.overtime,
      JobBenefit.travelExpenses,
    },
    immigrationSupport: {
      ImmigrationSupport.pnp,
      ImmigrationSupport.lmia,
      ImmigrationSupport.jobOffer,
    },
  ),
  Job(
    id: 'j11',
    title: 'Bilingual Customer Success Specialist',
    company: 'Lightspeed',
    location: 'Montréal, Quebec',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 60000,
    salaryHigh: 75000,
    category: 'Customer Service',
    postedHoursAgo: 96,
    searchCount: 2760,
    permitFriendly: true,
    nocCode: '64409',
    summary: 'Support retail and hospitality merchants in French and English.',
    description: [
      'Lightspeed provides point-of-sale systems to retailers and '
          'restaurants. As a Bilingual Customer Success Specialist, you will '
          'help merchants get set up and solve problems in French and English.',
      'You will handle calls, chats and emails, and make sure every issue '
          'you log reaches the team that can fix it.',
    ],
    duties: [
      'Answer merchant questions by phone, chat and email',
      'Walk new merchants through setting up their system',
      'Log product issues and follow them through to a fix',
      'Keep help articles accurate in both languages',
    ],
    experience: 'Two years or more in a customer-facing role',
    education: 'High school diploma; a college diploma is an asset',
    certifications: [],
    skills: ['French', 'English', 'Troubleshooting', 'Zendesk', 'Patience'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j12',
    title: 'Junior Accountant',
    company: 'MNP',
    location: 'Winnipeg, Manitoba',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 55000,
    salaryHigh: 68000,
    category: 'Accounting',
    postedHoursAgo: 168,
    searchCount: 2540,
    permitFriendly: true,
    nocCode: '11100',
    summary: 'Assurance and tax work for owner-managed businesses across the '
        'prairies.',
    description: [
      'MNP is one of Canada\'s largest accounting and consulting firms. The '
          'Winnipeg office is hiring a Junior Accountant to support '
          'owner-managed businesses across the prairies.',
      'You will prepare financial statements and tax returns, support audit '
          'work, and be supported through the CPA program with study time and '
          'paid exam fees.',
    ],
    duties: [
      'Prepare financial statements for small businesses',
      'Prepare personal and corporate tax returns',
      'Support senior staff on audit and review engagements',
      'Meet clients to gather records and answer questions',
    ],
    experience: 'One year or more in accounting, including co-op placements',
    education: 'Accounting degree, or an equivalent credential assessment',
    certifications: ['Enrolled in the CPA Professional Education Program'],
    skills: ['Financial statements', 'Tax preparation', 'Excel', 'CaseWare'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.overtime},
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j13',
    title: 'Warehouse Team Lead',
    company: 'Canadian Tire',
    location: 'Brampton, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 52000,
    salaryHigh: 62000,
    category: 'Logistics',
    postedHoursAgo: 120,
    searchCount: 3650,
    permitFriendly: true,
    nocCode: '12013',
    summary: 'Lead a shift team in a high-volume distribution centre.',
    description: [
      'Canadian Tire\'s Brampton distribution centre ships products to '
          'stores across Ontario. As a Warehouse Team Lead, you will run a '
          'shift team of 12 or more and keep orders moving safely and on time.',
      'You will assign work, track targets, train new team members and make '
          'safety part of every shift.',
    ],
    duties: [
      'Lead a team of 12 or more through each shift',
      'Assign work and track picking and shipping targets',
      'Run safety checks and report incidents',
      'Train new team members on equipment and procedures',
    ],
    experience: 'Two years or more in warehousing, including leading a team',
    education: 'High school diploma',
    certifications: [
      'Forklift operator certification (an asset)',
      'Workplace Hazardous Materials Information System (WHMIS)',
    ],
    skills: ['Team leadership', 'Inventory systems', 'Safety', 'Scheduling'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.overtime},
    immigrationSupport: {ImmigrationSupport.lmia},
  ),
  Job(
    id: 'j14',
    title: 'Software Engineer, Backend',
    company: 'Coveo',
    location: 'Québec City, Quebec',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 95000,
    salaryHigh: 125000,
    category: 'Programming',
    postedHoursAgo: 30,
    searchCount: 4410,
    permitFriendly: true,
    nocCode: '21231',
    summary: 'Work on relevance infrastructure serving billions of queries.',
    description: [
      'Coveo builds AI search used by major retailers and software '
          'companies. As a Backend Software Engineer, you will work on the '
          'services that return relevant results for billions of queries.',
      'You will design and build distributed services, improve their '
          'reliability, and share on-call duties with a team that writes '
          'careful post-incident reviews.',
    ],
    duties: [
      'Design and build services for the search platform',
      'Improve reliability and response times at scale',
      'Write automated tests and review code',
      'Take part in the on-call rotation',
    ],
    experience: 'Four years or more building production services',
    education: "Bachelor's degree in computer science or software engineering",
    certifications: [],
    skills: ['Java', 'Go', 'Distributed systems', 'AWS', 'Kubernetes'],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.bonus,
      JobBenefit.travelExpenses,
    },
    immigrationSupport: {ImmigrationSupport.lmia, ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j15',
    title: 'Graphic Designer',
    company: 'Indigo',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.temporary],
    salaryLow: 62000,
    salaryHigh: 78000,
    category: 'Design',
    postedHoursAgo: 168,
    searchCount: 760,
    permitFriendly: false,
    nocCode: '52120',
    summary: 'Twelve-month contract covering seasonal campaign work.',
    description: [
      'Indigo is Canada\'s largest bookseller. This twelve-month contract '
          'covers the busy seasonal campaigns, including the holiday period.',
      'You will design in-store signage and printed material, then adapt '
          'each campaign for the web, email and social media.',
    ],
    duties: [
      'Design in-store signage and printed campaign material',
      'Adapt campaigns for web, email and social',
      'Prepare print-ready files and check proofs',
    ],
    experience: 'Two years or more in graphic design, print and digital',
    education: 'Diploma or degree in graphic design',
    certifications: [],
    skills: ['Typography', 'Adobe InDesign', 'Illustrator', 'Print production'],
    benefits: {JobBenefit.healthInsurance},
    immigrationSupport: {},
  ),
  Job(
    id: 'j16',
    title: 'Freelance Brand Designer',
    company: 'Field Trip Studio',
    location: 'Remote, Canada',
    types: [Employment.partTime, Employment.temporary],
    salaryLow: 70000,
    salaryHigh: 95000,
    category: 'Design',
    postedHoursAgo: 72,
    searchCount: 520,
    permitFriendly: true,
    nocCode: '52120',
    summary: 'Project-based identity work for early-stage clients.',
    description: [
      'Field Trip Studio is a small brand studio working with early-stage '
          'companies. This is ongoing, project-based work you can do from '
          'anywhere in Canada.',
      'You will design identity systems from logo to guidelines and run the '
          'client relationship yourself, at least three days a week.',
    ],
    duties: [
      'Design logos, type systems and brand guidelines',
      'Present concepts directly to clients',
      'Manage your own project timelines',
    ],
    experience: 'A portfolio of identity systems for real clients',
    education: 'No formal education required',
    certifications: [],
    skills: ['Brand identity', 'Illustrator', 'Client management'],
    benefits: {},
    immigrationSupport: {},
  ),
  Job(
    id: 'j17',
    title: 'Product Marketing Associate',
    company: 'Ada',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 72000,
    salaryHigh: 90000,
    category: 'Marketing',
    postedHoursAgo: 144,
    searchCount: 1280,
    permitFriendly: true,
    nocCode: '11202',
    summary: 'Position an AI customer-service product for enterprise buyers.',
    description: [
      'Ada builds AI-powered customer service for large companies. As a '
          'Product Marketing Associate, you will help explain what the product '
          'does and why it matters to enterprise buyers.',
      'You will write launch material, interview customers, and prepare the '
          'sales team for each new release.',
    ],
    duties: [
      'Write product messaging and launch material',
      'Interview customers to understand why they buy',
      'Prepare sales teams for each launch',
    ],
    experience: 'Two years or more in product marketing',
    education: "Bachelor's degree in marketing, business or a related field",
    certifications: [],
    skills: ['Positioning', 'Copywriting', 'Customer interviews'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {ImmigrationSupport.jobOffer},
  ),
  Job(
    id: 'j18',
    title: 'Design Intern',
    company: 'Shopify',
    location: 'Ottawa, Ontario',
    types: [Employment.fullTime, Employment.temporary],
    salaryLow: 45000,
    salaryHigh: 55000,
    category: 'Design',
    postedHoursAgo: 46,
    searchCount: 480,
    permitFriendly: true,
    nocCode: '21233',
    summary: 'Four-month internship on a product team, with a mentor.',
    description: [
      'Shopify\'s internship program places students on real product teams '
          'for a four-month term. You will design features that ship, with a '
          'senior designer as your mentor.',
      'You will join research sessions, take part in design reviews, and '
          'present what you built at the end of the term.',
    ],
    duties: [
      'Design features alongside a senior designer',
      'Join user research sessions and take notes',
      'Present your work at the end of the term',
    ],
    experience: 'None required — a portfolio of student or personal work',
    education: 'Currently enrolled in a design or related program',
    certifications: [],
    skills: ['Figma', 'Visual design', 'Curiosity'],
    benefits: {JobBenefit.travelExpenses},
    immigrationSupport: {},
  ),
  Job(
    id: 'j19',
    title: 'Early Childhood Educator',
    company: 'YMCA of Greater Toronto',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 48000,
    salaryHigh: 58000,
    category: 'Education',
    postedHoursAgo: 96,
    searchCount: 2950,
    permitFriendly: true,
    nocCode: '42202',
    summary: 'Full-time position in a licensed centre serving three to five '
        'year olds.',
    description: [
      'The YMCA of Greater Toronto runs licensed child care centres across '
          'the city. This full-time role is in a centre serving children aged '
          'three to five.',
      'You will plan play-based learning, observe each child\'s '
          'development, and build strong relationships with families.',
    ],
    duties: [
      'Plan and lead play-based learning activities',
      'Observe and record each child’s development',
      'Keep the room safe, clean and welcoming',
      'Talk with families at drop-off and pick-up',
    ],
    experience: 'One year or more in a licensed child care setting',
    education: 'Early Childhood Education diploma',
    certifications: [
      'Registration with the College of Early Childhood Educators',
      'Standard First Aid and CPR-C',
      'Vulnerable sector police check',
    ],
    skills: ['Child development', 'Lesson planning', 'Communication'],
    benefits: {JobBenefit.healthInsurance},
    immigrationSupport: {
      ImmigrationSupport.pnp,
      ImmigrationSupport.lmia,
      ImmigrationSupport.jobOffer,
    },
  ),
  Job(
    id: 'j20',
    title: 'Electrician (Construction)',
    company: 'PCL Construction',
    location: 'Saskatoon, Saskatchewan',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 72000,
    salaryHigh: 95000,
    category: 'Trades',
    postedHoursAgo: 168,
    searchCount: 3870,
    permitFriendly: true,
    nocCode: '72200',
    summary: 'Commercial construction projects across Saskatchewan.',
    description: [
      'PCL Construction is hiring journeyperson electricians for commercial '
          'projects across Saskatchewan, including hospitals, schools and '
          'offices.',
      'You will install and test electrical systems to code. Travel between '
          'sites is paid, and accommodation is provided for projects outside '
          'Saskatoon.',
    ],
    duties: [
      'Install wiring, panels and lighting on commercial sites',
      'Read blueprints and electrical drawings',
      'Test systems and fix faults',
      'Follow the Canadian Electrical Code and site safety rules',
    ],
    experience: 'Three years or more on commercial or industrial projects',
    education: 'Completed electrical apprenticeship',
    certifications: [
      'Journeyperson certificate, or Red Seal equivalency',
      'Valid driving licence',
    ],
    skills: ['Blueprint reading', 'Conduit bending', 'Troubleshooting'],
    benefits: {
      JobBenefit.healthInsurance,
      JobBenefit.overtime,
      JobBenefit.travelExpenses,
      JobBenefit.accommodation,
    },
    immigrationSupport: {
      ImmigrationSupport.pnp,
      ImmigrationSupport.lmia,
      ImmigrationSupport.jobOffer,
    },
  ),
  Job(
    id: 'j21',
    title: 'HR Business Partner',
    company: 'Sun Life',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 88000,
    salaryHigh: 110000,
    category: 'Human Resources',
    postedHoursAgo: 120,
    searchCount: 1980,
    permitFriendly: false,
    nocCode: '11200',
    summary: 'Partner with technology leaders on talent and organisational '
        'design.',
    description: [
      'Sun Life is a leading financial services company. As an HR Business '
          'Partner, you will support technology leaders with hiring, '
          'performance and team design.',
      'You will lead the yearly talent review for your group, coach '
          'managers, and handle employee relations cases with care.',
    ],
    duties: [
      'Advise technology leaders on hiring, performance and team structure',
      'Lead the yearly talent review for your group',
      'Handle employee relations cases',
    ],
    experience: 'Six years or more in human resources, supporting technical '
        'teams',
    education: "Bachelor's degree in human resources or business",
    certifications: ['CHRP designation (an asset)'],
    skills: ['Employee relations', 'Talent planning', 'Coaching'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {},
  ),
  Job(
    id: 'j22',
    title: 'Sous Chef',
    company: 'Fairmont Banff Springs',
    location: 'Banff, Alberta',
    types: [Employment.fullTime, Employment.seasonal],
    salaryLow: 55000,
    salaryHigh: 68000,
    category: 'Hospitality',
    postedHoursAgo: 72,
    searchCount: 3180,
    permitFriendly: true,
    nocCode: '62200',
    summary: 'Hotel kitchen for the summer season, staff accommodation '
        'provided.',
    description: [
      'Fairmont Banff Springs is a historic hotel in Banff National Park. '
          'This seasonal Sous Chef role runs from May to October in one of the '
          'hotel\'s busiest kitchens.',
      'You will lead the line when the executive chef is away, control food '
          'costs and train cooks. Staff accommodation in Banff is provided at a '
          'low cost, and relocation travel is covered.',
    ],
    duties: [
      'Run the kitchen line when the executive chef is away',
      'Prepare and plate dishes to hotel standards',
      'Order stock and control food costs',
      'Train and supervise cooks',
    ],
    experience: 'Three years or more in a high-volume kitchen',
    education: 'Culinary diploma or equivalent experience',
    certifications: [
      'Red Seal cook certification or equivalent',
      'Food Safety certificate',
    ],
    skills: ['Line management', 'Menu costing', 'Food safety'],
    benefits: {
      JobBenefit.accommodation,
      JobBenefit.healthInsurance,
      JobBenefit.travelExpenses,
      JobBenefit.overtime,
    },
    immigrationSupport: {ImmigrationSupport.pnp, ImmigrationSupport.lmia},
  ),
  Job(
    id: 'j23',
    title: 'Executive Assistant',
    company: 'Ontario Teachers Pension Plan',
    location: 'Toronto, Ontario',
    types: [Employment.fullTime, Employment.permanent],
    salaryLow: 68000,
    salaryHigh: 82000,
    category: 'Administration',
    postedHoursAgo: 168,
    searchCount: 1420,
    permitFriendly: false,
    nocCode: '13110',
    summary: 'Support two managing directors in a fast investment environment.',
    description: [
      'Ontario Teachers\' Pension Plan invests on behalf of Ontario\'s '
          'teachers. As an Executive Assistant, you will support two managing '
          'directors in a fast-moving investment team.',
      'You will manage calendars, travel and documents, and handle '
          'confidential information with complete discretion.',
    ],
    duties: [
      'Manage calendars, travel and meetings for two directors',
      'Prepare documents and presentations',
      'Handle confidential information with discretion',
    ],
    experience: 'Five years or more supporting senior executives',
    education: 'College diploma in office administration or a related field',
    certifications: [],
    skills: ['Calendar management', 'Microsoft 365', 'Discretion'],
    benefits: {JobBenefit.healthInsurance, JobBenefit.bonus},
    immigrationSupport: {},
  ),
  Job(
    id: 'j24',
    title: 'Research Associate, Public Health',
    company: 'University of British Columbia',
    location: 'Vancouver, British Columbia',
    types: [Employment.fullTime, Employment.temporary],
    salaryLow: 65000,
    salaryHigh: 80000,
    category: 'Research',
    postedHoursAgo: 3,
    searchCount: 640,
    permitFriendly: true,
    nocCode: '41400',
    summary: 'Two-year funded position on a newcomer health outcomes study.',
    description: [
      'The University of British Columbia is hiring a Research Associate '
          'for a two-year funded study on the health of newcomers to Canada.',
      'You will collect and analyse survey data, prepare tables and '
          'figures, and help write reports and journal articles with the '
          'research team.',
    ],
    duties: [
      'Collect and clean study data',
      'Run statistical analyses and prepare tables',
      'Help write reports and journal articles',
    ],
    experience: 'Two years or more of quantitative research',
    education: "Master's degree in public health or a related field",
    certifications: [],
    skills: ['R', 'Statistics', 'Academic writing', 'Survey data'],
    benefits: {JobBenefit.healthInsurance},
    immigrationSupport: {ImmigrationSupport.jobOffer},
  ),
];

/// How many roles the Most searched bar shows, and how many to a swipe.
const int mockTopJobsCount = 15;
const int mockTopJobsPerPage = 5;

/// The filter options on the search sheet.
const List<String> mockFieldsOfWork = [
  'All',
  'Design',
  'Content',
  'Marketing',
  'Programming',
  'Engineering',
  'Healthcare',
  'Education',
  'Trades',
  'Logistics',
  'Hospitality',
  'Accounting',
  'Customer Service',
  'Human Resources',
  'Administration',
  'Research',
];

/// The salary slider's ends. The board runs from 45k to 145k, so the ends sit
/// just outside it and every job is inside the default range.
const int mockSalaryFloor = 40000;
const int mockSalaryCeiling = 160000;
const int mockSalaryStep = 10000;

/// One-tap picks under the location field. Typing covers everywhere else.
const List<String> mockLocations = [
  'Ontario',
  'British Columbia',
  'Alberta',
  'Quebec',
  'Manitoba',
  'Saskatchewan',
  'Remote',
];
