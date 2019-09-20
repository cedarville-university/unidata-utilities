##############################
## example of shared defaults
## Created: 12-JAN-2000 dlr
##############################


$currentFiscalYear = "2002";
$nextFiscalYear = "2003";
$currentAcademicYear = "2001";
$nextAcademicYear = "2002";

  %InquiryQtrLabels = (
    '1999FA', 'Fall Quarter 1999',
    '2000WI', 'Winter Quarter 2000',
    '2000SP', 'Spring Quarter 2000',
    '2000S1', 'Summer I 2000',
    '2000S2', 'Summer II 2000',
    '2000S3', 'Summer III 2000',
    '2000FA', 'Fall Quarter 2000',
    '2001WI', 'Winter Quarter 2001',
    '2001SP', 'Spring Quarter 2001',
    '2001SS', 'Spring Semester 2001',
    '2001S1', 'Summer I 2001',
    '2001S2', 'Summer II 2001',
    '2001S3', 'Summer III 2001',
    '2001S4', 'Summer IV 2001',
    '2001G1', 'Graduate Summer 1 2001',
    '2001G2', 'Graduate Summer 2 2001',
    '2001G3', 'Graduate Summer 3 2001',
    '2001FA', 'Fall Quarter 2001',
    '2001FS', 'Fall Semester 2001',
    '2002WI', 'Winter Quarter 2002',
    '2002SP', 'Spring Quarter 2002',
    '2002SS', 'Spring Semester 2002',
    '2002S1', 'Summer I 2002',
    '2002S2', 'Summer II 2002',
    '2002S3', 'Summer III 2002',
    '2002S4', 'Summer IV 2002',
  );

  @InquiryQtrValues = (
    '1999FA', '2000WI', '2000SP', '2000S1', '2000S2', '2000S3', 
    '2000FA', '2001WI', '2001SP', '2001SS', '2001S1', '2001S2', '2001S3', '2001S4', '2001G1', '2001G2', '2001G3',
    '2001FA', '2001FS', '2002WI', '2002SP', '2002SS', '2002S1', '2002S2', '2002S3', '2002S4',
  );
  $defaultInquiryTerm = '2001FA';
 
  %RegistrationQtrLabels = (
    '2002WI', 'Winter Quarter 2002',
    '2001FS', 'Fall Semester 2001',
    '2002SS', 'Spring Semester 2002',
  );

  @RegistrationQtrValues = (
    '2002WI',
    '2001FS',
    '2002SS',
  );

  $defaultRegistrationTerm = '2002WI';


  %GradingQtrLabels = (
    '2001S2', 'Summer Session II',
    '2001S3', 'Summer Session III',
    '2001S4', 'Summer Session IV',
    '2001FA', 'Fall Quarter 2001',
    '2001FS', 'Fall Semester 2001',
    '2002SS', 'Spring Semester 2002',
  );

  @GradingQtrValues = (
    '2001S2',
    '2001S3',
    '2001S4',
    '2001FA',
    '2001FS',
    '2002SS',
  );
  $defaultGradingTerm = '2001FA';

  %MealPlanQtrLabels = (
    '2002WI', 'Winter Quarter 2002WI',
  );

  @MealPlanQtrValues = (
    '2002WI',
  );
 
  $defaultMealPlanTerm = '2002WI';


1;
