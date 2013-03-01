# ================================================================
# sequence generators

module SequenceHelpers

  FIRST_NAMES = %w( Aaron Abby Abdul Abe Abel Abigail Abraham Abram
      Ada Adalberto Adam Adan Addie Adela Adele Adeline Adolfo Adolph
      Adrian Adriana Adrienne Agnes Agustin Ahmad Ahmed Aida Aileen
      Aimee Aisha Al Alan Alana Alba Albert Alberta Alberto Alden Aldo
      Alec Alejandra Alejandro Alex Alexander Alexandra Alexandria
      Alexis Alfonso Alfonzo Alfred Alfreda Alfredo Ali Alice Alicia
      Aline Alisa Alisha Alison Alissa Allan Allen Allie Allison Allyson
      Alma Alonso Alonzo Alphonse Alphonso Alta Althea Alton Alva Alvaro
      Alvin Alyce Alyson Alyssa Amado Amalia Amanda Amber Ambrose Amelia
      Amie Amos Amparo Amy Ana Anastasia Anderson Andre Andrea Andreas
      Andres Andrew Andy Angel Angela Angelia Angelica Angelina Angeline
      Angelique Angelita Angelo Angie Anibal Anita Ann Anna Annabelle
      Anne Annette Annie Annmarie Anthony Antione Antoine Antoinette
      Anton Antone Antonia Antonio Antony Antwan April Araceli Archie
      Arden Ariel Arlen Arlene Arlie Arline Armand Armando Arnold
      Arnoldo Arnulfo Aron Arron Art Arthur Arturo Asa Ashlee Ashley
      Aubrey Audra Audrey August Augusta Augustine Augustus Aurelia
      Aurelio Aurora Austin Autumn Ava Avery Avis Barbara Barbra Barney
      Barrett Barry Bart Barton Basil Beatrice Beatriz Beau Becky
      Belinda Ben Benedict Benita Benito Benjamin Bennett Bennie Benny
      Benton Bernadette Bernadine Bernard Bernardo Bernice Bernie Berry
      Bert Berta Bertha Bertie Bertram Beryl Bessie Beth Bethany Betsy
      Bette Bettie Betty Bettye Beulah Beverley Beverly Bianca Bill
      Billie Billy Blaine Blair Blake Blanca Blanche Bo Bob Bobbi Bobbie
      Bobby Bonita Bonnie Booker Boris Boyce Boyd Brad Bradford Bradley
      Bradly Brady Brain Branden Brandi Brandie Brandon Brandy Brant
      Brenda Brendan Brendon Brent Brenton Bret Brett Brian Briana
      Brianna Brice Bridget Bridgett Bridgette Brigitte Britney Britt
      Brittany Brittney Brock Broderick Brooke Brooks Bruce Bruno Bryan
      Bryant Bryce Bryon Buck Bud Buddy Buford Burl Burt Burton Buster
      Byron Caitlin Caleb Callie Calvin Cameron Camille Candace Candice
      Candy Cara Carey Carissa Carl Carla Carlene Carlo Carlos Carlton
      Carly Carmela Carmella Carmelo Carmen Carmine Carol Carole
      Carolina Caroline Carolyn Carrie Carrol Carroll Carson Carter Cary
      Casandra Casey Cassandra Cassie Catalina Catherine Cathleen
      Cathryn Cathy Cecelia Cecil Cecile Cecilia Cedric Cedrick Celeste
      Celia Celina Cesar Chad Chadwick Chance Chandra Chang Charity
      Charlene Charles Charley Charlie Charlotte Charmaine Chas Chase
      Chasity Chauncey Chelsea Cheri Cherie Cherry Cheryl Chester Chet
      Chi Chong Chris Christa Christi Christian Christie Christina
      Christine Christoper Christopher Christy Chrystal Chuck Chung
      Cindy Clair Claire Clara Clare Clarence Clarice Clarissa Clark
      Claud Claude Claudette Claudia Claudine Claudio Clay Clayton
      Clement Clemente Cleo Cletus Cleveland Cliff Clifford Clifton
      Clint Clinton Clyde Cody Colby Cole Coleen Coleman Colette Colin
      Colleen Collin Colton Columbus Concepcion Concetta Connie Conrad
      Constance Consuelo Cora Cordell Corey Corina Corine Corinne
      Cornelia Cornelius Cornell Corrine Cortez Cory Courtney Coy Craig
      Cristina Cristobal Cristopher Cruz Crystal Curt Curtis Cynthia
      Cyril Cyrus Daisy Dale Dallas Dalton Damian Damien Damion Damon
      Dan Dana Dane Danial Daniel Danielle Danilo Dannie Danny Dante
      Daphne Darcy Darell Daren Darin Dario Darius Darla Darlene Darnell
      Daron Darrel Darrell Darren Darrick Darrin Darron Darryl Darwin
      Daryl Dave David Davis Dawn Dean Deana Deandre Deangelo Deann
      Deanna Deanne Debbie Debora Deborah Debra Dee Deena Deidre Deirdre
      Del Delbert Delia Della Delmar Delmer Delores Deloris Demarcus
      Demetrius Dena Denice Denis Denise Dennis Denny Denver Deon Derek
      Derick Derrick Deshawn Desiree Desmond Devin Devon Dewayne Dewey
      Dewitt Dexter Diana Diane Diann Dianna Dianne Dick Diego Dillon
      Dina Dino Dion Dionne Dirk Dixie Dollie Dolly Dolores Domenic
      Domingo Dominic Dominick Dominique Don Dona Donald Dong Donn Donna
      Donnell Donnie Donny Donovan Donte Dora Doreen Dorian Doris
      Dorothea Dorothy Dorsey Dorthy Doug Douglas Douglass Doyle Drew
      Duane Dudley Duncan Dustin Dusty Dwain Dwayne Dwight Dylan Earl
      Earle Earlene Earline Earnest Earnestine Ebony Ed Eddie Eddy Edgar
      Edgardo Edison Edith Edmond Edmund Edmundo Edna Eduardo Edward
      Edwardo Edwin Edwina Effie Efrain Efren Eileen Elaine Elba Elbert
      Elden Eldon Eldridge Eleanor Elena Eli Elias Elijah Elinor Elisa
      Elisabeth Elise Eliseo Elisha Eliza Elizabeth Ella Ellen Elliot
      Elliott Ellis Ellsworth Elma Elmer Elmo Elnora Eloise Eloy Elroy
      Elsa Elsie Elton Elva Elvia Elvin Elvira Elvis Elwood Emanuel
      Emerson Emery Emil Emile Emilia Emilio Emily Emma Emmanuel Emmett
      Emmitt Emory Enid Enoch Enrique Erasmo Eric Erica Erich Erick
      Ericka Erik Erika Erin Erma Erna Ernest Ernestine Ernesto Ernie
      Errol Ervin Erwin Esmeralda Esperanza Essie Esteban Estela Estella
      Estelle Ester Esther Ethan Ethel Etta Eugene Eugenia Eugenio Eula
      Eunice Eusebio Eva Evan Evangelina Evangeline Eve Evelyn Everett
      Everette Ezekiel Ezequiel Ezra Fabian Faith Fannie Fanny Faustino
      Fausto Fay Faye Federico Felecia Felicia Felipe Felix Felton
      Ferdinand Fermin Fern Fernando Fidel Filiberto Fletcher Flora
      Florence Florencio Florentino Florine Flossie Floyd Forest Forrest
      Foster Fran Frances Francesca Francesco Francine Francis Francisca
      Francisco Frank Frankie Franklin Franklyn Fred Freda Freddie
      Freddy Frederic Frederick Fredric Fredrick Freeman Freida Frieda
      Fritz Gabriel Gabriela Gabrielle Gail Gale Galen Garfield Garland
      Garret Garrett Garry Garth Gary Gaston Gavin Gay Gayle Gaylord
      Gena Genaro Gene Geneva Genevieve Geoffrey George Georgette
      Georgia Georgina Gerald Geraldine Geraldo Gerard Gerardo German
      Gerry Gertrude Gil Gilbert Gilberto Gilda Gina Ginger Gino
      Giovanni Giuseppe Gladys Glen Glenda Glenn Glenna Gloria Goldie
      Gonzalo Gordon Grace Gracie Graciela Grady Graham Graig Grant
      Granville Greg Gregg Gregorio Gregory Greta Gretchen Grover
      Guadalupe Guillermo Gus Gustavo Guy Gwen Gwendolyn Hai Hal Haley
      Hallie Hank Hannah Hans Harlan Harland Harley Harold Harriet
      Harriett Harris Harrison Harry Harvey Hassan Hattie Hayden Haywood
      Hazel Heath Heather Hector Heidi Helen Helena Helene Helga
      Henrietta Henry Herb Herbert Heriberto Herman Herminia Herschel
      Hershel Hester Hilario Hilary Hilda Hillary Hilton Hipolito Hiram
      Hobert Hollie Hollis Holly Homer Hong Hope Horace Horacio Hosea
      Houston Howard Hoyt Hubert Huey Hugh Hugo Humberto Hung Hunter
      Hyman Ian Ida Ignacio Ike Ila Ilene Imelda Imogene Ina Ines Inez
      Ingrid Ira Irene Iris Irma Irvin Irving Irwin Isaac Isabel
      Isabella Isabelle Isaiah Isaias Isiah Isidro Ismael Israel Isreal
      Issac Iva Ivan Ivory Ivy Jacinto Jack Jackie Jacklyn Jackson
      Jaclyn Jacob Jacqueline Jacquelyn Jacques Jade Jae Jaime Jake
      Jamaal Jamal Jamar Jame Jamel James Jamey Jami Jamie Jamison Jan
      Jana Jane Janell Janelle Janet Janette Janice Janie Janine Janis
      Janna Jannie Jared Jarod Jarred Jarrett Jarrod Jarvis Jasmine
      Jason Jasper Javier Jay Jayne Jayson Jc Jean Jeanette Jeanie
      Jeanine Jeanne Jeannette Jeannie Jeannine Jed Jeff Jefferey
      Jefferson Jeffery Jeffrey Jeffry Jenifer Jenna Jennie Jennifer
      Jenny Jerald Jeramy Jere Jeremiah Jeremy Jeri Jermaine Jerold
      Jerome Jeromy Jerrell Jerri Jerrod Jerrold Jerry Jess Jesse
      Jessica Jessie Jesus Jewel Jewell Jill Jillian Jim Jimmie Jimmy Jo
      Joan Joann Joanna Joanne Joaquin Jocelyn Jodi Jodie Jody Joe Joel
      Joesph Joey Johanna John Johnathan Johnathon Johnie Johnnie Johnny
      Johnson Jolene Jon Jonah Jonas Jonathan Jonathon Joni Jordan
      Jordon Jorge Jose Josef Josefa Josefina Joseph Josephine Josh
      Joshua Josiah Josie Jospeh Josue Joy Joyce Juan Juana Juanita Jude
      Judith Judson Judy Jules Julia Julian Juliana Julianne Julie
      Juliet Juliette Julio Julius June Junior Justin Justine Kaitlin
      Kara Kareem Karen Kari Karin Karina Karl Karla Karyn Kasey Kate
      Katelyn Katharine Katherine Katheryn Kathie Kathleen Kathrine
      Kathryn Kathy Katie Katina Katrina Katy Kay Kaye Kayla Keenan
      Keisha Keith Kelley Kelli Kellie Kelly Kelsey Kelvin Ken Kendall
      Kendra Kendrick Keneth Kenneth Kennith Kenny Kent Kenton Kenya
      Keri Kermit Kerri Kerry Keven Kevin Kieth Kim Kimberley Kimberly
      King Kip Kirby Kirk Kirsten Kitty Korey Kory Kraig Kris Krista
      Kristen Kristi Kristie Kristin Kristina Kristine Kristofer
      Kristopher Kristy Krystal Kurt Kurtis Kyle Lacey Lacy Ladonna
      Lakeisha Lakisha Lamar Lamont Lana Lance Landon Lane Lanny Lara
      Larry Latasha Latisha Latonya Latoya Laura Laurel Lauren Laurence
      Lauri Laurie Lavern Laverne Lavonne Lawanda Lawerence Lawrence
      Lazaro Lea Leah Leandro Leann Leanna Leanne Lee Leif Leigh Leila
      Lela Leland Lelia Lemuel Len Lena Lenard Lenny Lenora Lenore Leo
      Leola Leon Leona Leonard Leonardo Leonel Leonor Leopoldo Leroy Les
      Lesa Lesley Leslie Lessie Lester Leta Letha Leticia Letitia Levi
      Lewis Lidia Lila Lilia Lilian Liliana Lillian Lillie Lilly Lily
      Lina Lincoln Linda Lindsay Lindsey Lino Linwood Lionel Lisa Liz
      Liza Lizzie Lloyd Logan Lois Lola Lolita Lon Long Lonnie Lonny
      Lora Loraine Loren Lorena Lorene Lorenzo Loretta Lori Lorie Lorna
      Lorraine Lorrie Lottie Lou Louella Louie Louis Louisa Louise
      Lourdes Lowell Loyd Luann Lucas Lucia Luciano Lucien Lucile
      Lucille Lucinda Lucio Lucius Lucy Luella Luigi Luis Luisa Luke
      Lula Lupe Luther Luz Lydia Lyle Lyman Lynda Lyndon Lynette Lynn
      Lynne Lynnette Lynwood Mabel Mable Mac Mack Madeleine Madeline
      Madelyn Madge Mae Magdalena Maggie Mai Major Malcolm Malcom Malik
      Malinda Mallory Mamie Man Mandy Manual Manuel Manuela Mara Marc
      Marcel Marcelino Marcella Marcellus Marcelo Marci Marcia Marcie
      Marco Marcos Marcus Marcy Margaret Margarita Margarito Margery
      Margie Margo Margret Marguerite Mari Maria Marian Mariana Marianne
      Mariano Maribel Maricela Marie Marietta Marilyn Marina Mario
      Marion Marisa Marisol Marissa Maritza Marjorie Mark Markus Marla
      Marlene Marlin Marlon Marquis Marquita Marsha Marshall Marta
      Martha Martin Martina Marty Marva Marvin Mary Maryann Maryanne
      Maryellen Marylou Mason Mathew Matilda Matt Matthew Mattie Maude
      Maura Maureen Maurice Mauricio Mauro Mavis Max Maximo Maxine
      Maxwell May Maynard Mayra Mckinley Meagan Megan Meghan Mel Melanie
      Melba Melinda Melisa Melissa Melody Melva Melvin Mercedes Meredith
      Merle Merlin Merrill Mervin Mia Micah Michael Michal Michale
      Micheal Michel Michele Michelle Mickey Miguel Mike Mikel Milagros
      Milan Mildred Miles Milford Millard Millicent Millie Milo Milton
      Mindy Minerva Minh Minnie Miquel Miranda Miriam Misty Mitch
      Mitchel Mitchell Mitzi Modesto Mohamed Mohammad Mohammed Moises
      Mollie Molly Mona Monica Monique Monroe Monte Monty Morgan Morris
      Morton Mose Moses Moshe Muriel Murray Myles Myra Myrna Myron
      Myrtle Nadia Nadine Nancy Nanette Nannie Naomi Napoleon Natalia
      Natalie Natasha Nathan Nathanael Nathanial Nathaniel Neal Ned Neil
      Nelda Nell Nellie Nelson Nestor Nettie Neva Neville Newton
      Nicholas Nichole Nick Nickolas Nicky Nicolas Nicole Nigel Nikki
      Nina Nita Noah Noble Noe Noel Noelle Noemi Nola Nolan Nona Nora
      Norbert Norberto Noreen Norma Norman Normand Norris Numbers
      Octavia Octavio Odell Odessa Odis Ofelia Ola Olen Olga Olin Olive
      Oliver Olivia Ollie Omar Omer Opal Ophelia Ora Oren Orlando Orval
      Orville Oscar Osvaldo Oswaldo Otha Otis Otto Owen Pablo Paige
      Palmer Pam Pamela Pansy Paris Parker Pasquale Pat Patrica Patrice
      Patricia Patrick Patsy Patti Patty Paul Paula Paulette Pauline
      Pearl Pearlie Pedro Peggy Penelope Penny Percy Perry Pete Peter
      Petra Phil Philip Phillip Phoebe Phyllis Pierre Polly Porfirio
      Porter Preston Prince Priscilla Queen Quentin Quincy Quinn Quintin
      Quinton Rachael Rachel Rachelle Rae Rafael Raleigh Ralph Ramiro
      Ramon Ramona Randal Randall Randell Randi Randolph Randy Raphael
      Raquel Rashad Raul Ray Rayford Raymon Raymond Raymundo Reba
      Rebecca Rebekah Reed Refugio Reggie Regina Reginald Reid Reinaldo
      Rena Renaldo Renato Rene Renee Reuben Reva Rex Rey Reyes Reyna
      Reynaldo Rhea Rhett Rhoda Rhonda Ricardo Rich Richard Richie Rick
      Rickey Rickie Ricky Rico Rigoberto Riley Rita Rob Robbie Robby
      Roberta Roberto Robin Robt Robyn Rocco Rochelle Rocky Rod Roderick
      Rodger Rodney Rodolfo Rodrick Rodrigo Rogelio Roger Roland Rolando
      Rolf Rolland Roman Romeo Ron Ronald Ronda Ronnie Ronny Roosevelt
      Rory Rosa Rosalie Rosalind Rosalinda Rosalyn Rosanna Rosanne
      Rosario Roscoe Rose Roseann Rosella Rosemarie Rosemary Rosendo
      Rosetta Rosie Roslyn Ross Rowena Roxanne Roxie Roy Royal Royce
      Ruben Rubin Ruby Rudolf Rudolph Rudy Rueben Rufus Rupert Russ
      Russel Russell Rusty Ruth Ruthie Ryan Sabrina Sadie Sal Sallie
      Sally Salvador Salvatore Sam Samantha Sammie Sammy Samual Samuel
      Sandra Sandy Sanford Sang Santiago Santo Santos Sara Sarah Sasha
      Saul Saundra Savannah Scot Scott Scottie Scotty Sean Sebastian
      Selena Selma Serena Sergio Seth Seymour Shad Shana Shane Shanna
      Shannon Shari Sharlene Sharon Sharron Shaun Shauna Shawn Shawna
      Shayne Sheena Sheila Shelby Sheldon Shelia Shelley Shelly Shelton
      Sheree Sheri Sherman Sherri Sherrie Sherry Sherwood Sheryl Shirley
      Shon Sid Sidney Silas Silvia Simon Simone Socorro Sofia Sol
      Solomon Son Sondra Sonia Sonja Sonny Sonya Sophia Sophie Spencer
      Stacey Staci Stacie Stacy Stan Stanford Stanley Stanton Stefan
      Stefanie Stella Stephan Stephanie Stephen Sterling Steve Steven
      Stevie Stewart Stuart Sue Summer Sung Susan Susana Susanna Susanne
      Susie Suzanne Suzette Sybil Sydney Sylvester Sylvia Tabatha
      Tabitha Tad Tamara Tameka Tamera Tami Tamika Tammi Tammie Tammy
      Tamra Tania Tanisha Tanner Tanya Tara Tasha Taylor Ted Teddy
      Teodoro Terence Teresa Teri Terra Terrance Terrell Terrence Terri
      Terrie Terry Tessa Thad Thaddeus Thanh Thelma Theo Theodore
      Theresa Therese Theron Thomas Thurman Tia Tiffany Tim Timmy
      Timothy Tina Tisha Titus Tobias Toby Tod Todd Tom Tomas Tommie
      Tommy Toney Toni Tonia Tony Tonya Tori Tory Tracey Traci Tracie
      Tracy Travis Trent Trenton Trevor Trey Tricia Trina Trinidad
      Trisha Tristan Troy Trudy Truman Tuan Twila Ty Tyler Tyree Tyrell
      Tyron Tyrone Tyson Ulysses Ursula Val Valarie Valentin Valentine
      Valeria Valerie Van Vance Vanessa Vaughn Velma Vera Vern Verna
      Vernon Veronica Vicente Vicki Vickie Vicky Victor Victoria Vilma
      Vince Vincent Vincenzo Viola Violet Virgie Virgil Virgilio
      Virginia Vito Vivian Von Vonda Wade Waldo Walker Wallace Wally
      Walter Walton Wanda Ward Warner Warren Waylon Wayne Weldon Wendell
      Wendi Wendy Werner Wes Wesley Weston Whitney Wilber Wilbert Wilbur
      Wilburn Wilda Wiley Wilford Wilfred Wilfredo Will Willa Willard
      William Williams Willian Willie Willis Willy Wilma Wilmer Wilson
      Wilton Winford Winfred Winifred Winnie Winston Wm Woodrow Wyatt
      Xavier Yesenia Yolanda Yong Young Yvette Yvonne Zachariah Zachary
      Zachery Zack Zackary Zane Zelma ) 

  LAST_NAMES = %w(SMITH JOHNSON
      WILLIAMS BROWN JONES MILLER DAVIS GARCIA RODRIGUEZ WILSON MARTINEZ
      ANDERSON TAYLOR THOMAS HERNANDEZ MOORE MARTIN JACKSON THOMPSON
      WHITE LOPEZ LEE GONZALEZ HARRIS CLARK LEWIS ROBINSON WALKER PEREZ
      HALL YOUNG ALLEN SANCHEZ WRIGHT KING SCOTT GREEN BAKER ADAMS
      NELSON HILL RAMIREZ CAMPBELL MITCHELL ROBERTS CARTER PHILLIPS
      EVANS TURNER TORRES PARKER COLLINS EDWARDS STEWART FLORES MORRIS
      NGUYEN MURPHY RIVERA COOK ROGERS MORGAN PETERSON COOPER REED
      BAILEY BELL GOMEZ KELLY HOWARD WARD COX DIAZ RICHARDSON WOOD
      WATSON BROOKS BENNETT GRAY JAMES REYES CRUZ HUGHES PRICE MYERS
      LONG FOSTER SANDERS ROSS MORALES POWELL SULLIVAN RUSSELL ORTIZ
      JENKINS GUTIERREZ PERRY BUTLER BARNES FISHER HENDERSON COLEMAN
      SIMMONS PATTERSON JORDAN REYNOLDS HAMILTON GRAHAM KIM GONZALES
      ALEXANDER RAMOS WALLACE GRIFFIN WEST COLE HAYES CHAVEZ GIBSON
      BRYANT ELLIS STEVENS MURRAY FORD MARSHALL OWENS MCDONALD HARRISON
      RUIZ KENNEDY WELLS ALVAREZ WOODS MENDOZA CASTILLO OLSON WEBB
      WASHINGTON TUCKER FREEMAN BURNS HENRY VASQUEZ SNYDER SIMPSON
      CRAWFORD JIMENEZ PORTER MASON SHAW GORDON WAGNER HUNTER ROMERO
      HICKS DIXON HUNT PALMER ROBERTSON BLACK HOLMES STONE MEYER BOYD
      MILLS WARREN FOX ROSE RICE MORENO SCHMIDT PATEL FERGUSON NICHOLS
      HERRERA MEDINA RYAN FERNANDEZ WEAVER DANIELS STEPHENS GARDNER
      PAYNE KELLEY DUNN PIERCE ARNOLD TRAN SPENCER PETERS HAWKINS GRANT
      HANSEN CASTRO HOFFMAN HART ELLIOTT CUNNINGHAM KNIGHT BRADLEY
      CARROLL HUDSON DUNCAN ARMSTRONG BERRY ANDREWS JOHNSTON RAY LANE
      RILEY CARPENTER PERKINS AGUILAR SILVA RICHARDS WILLIS MATTHEWS
      CHAPMAN LAWRENCE GARZA VARGAS WATKINS WHEELER LARSON CARLSON
      HARPER GEORGE GREENE BURKE GUZMAN MORRISON MUNOZ JACOBS OBRIEN
      LAWSON FRANKLIN LYNCH BISHOP CARR SALAZAR AUSTIN MENDEZ GILBERT
      JENSEN WILLIAMSON MONTGOMERY HARVEY OLIVER HOWELL DEAN HANSON
      WEBER GARRETT SIMS BURTON FULLER SOTO MCCOY WELCH CHEN SCHULTZ
      WALTERS REID FIELDS WALSH LITTLE FOWLER BOWMAN DAVIDSON MAY DAY
      SCHNEIDER NEWMAN BREWER LUCAS HOLLAND WONG BANKS SANTOS CURTIS
      PEARSON DELGADO VALDEZ PENA RIOS DOUGLAS SANDOVAL BARRETT HOPKINS
      KELLER GUERRERO STANLEY BATES ALVARADO BECK ORTEGA WADE ESTRADA
      CONTRERAS BARNETT CALDWELL SANTIAGO LAMBERT POWERS CHAMBERS NUNEZ
      CRAIG LEONARD LOWE RHODES BYRD GREGORY SHELTON FRAZIER BECKER
      MALDONADO FLEMING VEGA SUTTON COHEN JENNINGS PARKS MCDANIEL WATTS
      BARKER NORRIS VAUGHN VAZQUEZ HOLT SCHWARTZ STEELE BENSON NEAL
      DOMINGUEZ HORTON TERRY WOLFE HALE LYONS GRAVES HAYNES MILES PARK
      WARNER PADILLA BUSH THORNTON MCCARTHY MANN ZIMMERMAN ERICKSON
      FLETCHER MCKINNEY PAGE DAWSON JOSEPH MARQUEZ REEVES KLEIN ESPINOZA
      BALDWIN MORAN LOVE ROBBINS HIGGINS BALL CORTEZ LE GRIFFITH BOWEN
      SHARP CUMMINGS RAMSEY HARDY SWANSON BARBER ACOSTA LUNA CHANDLER
      BLAIR DANIEL CROSS SIMON DENNIS OCONNOR QUINN GROSS NAVARRO MOSS
      FITZGERALD DOYLE MCLAUGHLIN ROJAS RODGERS STEVENSON SINGH YANG
      FIGUEROA HARMON NEWTON PAUL MANNING GARNER MCGEE REESE FRANCIS
      BURGESS ADKINS GOODMAN CURRY BRADY CHRISTENSEN POTTER WALTON
      GOODWIN MULLINS MOLINA WEBSTER FISCHER CAMPOS AVILA SHERMAN TODD
      CHANG BLAKE MALONE WOLF HODGES JUAREZ GILL FARMER HINES GALLAGHER
      DURAN HUBBARD CANNON MIRANDA WANG SAUNDERS TATE MACK HAMMOND
      CARRILLO TOWNSEND WISE INGRAM BARTON MEJIA AYALA SCHROEDER HAMPTON
      ROWE PARSONS FRANK WATERS STRICKLAND OSBORNE MAXWELL CHAN DELEON
      NORMAN HARRINGTON CASEY PATTON LOGAN BOWERS MUELLER GLOVER FLOYD
      HARTMAN BUCHANAN COBB FRENCH KRAMER MCCORMICK CLARKE TYLER GIBBS
      MOODY CONNER SPARKS MCGUIRE LEON BAUER NORTON POPE FLYNN HOGAN
      ROBLES SALINAS YATES LINDSEY LLOYD MARSH MCBRIDE OWEN SOLIS PHAM
      LANG PRATT LARA BROCK BALLARD TRUJILLO SHAFFER DRAKE ROMAN AGUIRRE
      MORTON STOKES LAMB PACHECO PATRICK COCHRAN SHEPHERD CAIN BURNETT
      HESS LI CERVANTES OLSEN BRIGGS OCHOA CABRERA VELASQUEZ MONTOYA
      ROTH MEYERS CARDENAS FUENTES WEISS HOOVER WILKINS NICHOLSON
      UNDERWOOD SHORT CARSON MORROW COLON HOLLOWAY SUMMERS BRYAN
      PETERSEN MCKENZIE SERRANO WILCOX CAREY CLAYTON POOLE CALDERON
      GALLEGOS GREER RIVAS GUERRA DECKER COLLIER WALL WHITAKER BASS
      FLOWERS DAVENPORT CONLEY HOUSTON HUFF COPELAND HOOD MONROE MASSEY
      ROBERSON COMBS FRANCO LARSEN PITTMAN RANDALL SKINNER WILKINSON
      KIRBY CAMERON BRIDGES ANTHONY RICHARD KIRK BRUCE SINGLETON MATHIS
      BRADFORD BOONE ABBOTT CHARLES ALLISON SWEENEY ATKINSON HORN
      JEFFERSON ROSALES YORK CHRISTIAN PHELPS FARRELL CASTANEDA NASH
      DICKERSON BOND WYATT FOLEY CHASE GATES VINCENT MATHEWS HODGE
      GARRISON TREVINO VILLARREAL HEATH DALTON VALENCIA CALLAHAN HENSLEY
      ATKINS HUFFMAN ROY BOYER SHIELDS LIN HANCOCK GRIMES GLENN CLINE
      DELACRUZ CAMACHO DILLON PARRISH ONEILL MELTON BOOTH KANE BERG
      HARRELL PITTS SAVAGE WIGGINS BRENNAN SALAS MARKS RUSSO SAWYER
      BAXTER GOLDEN HUTCHINSON LIU WALTER MCDOWELL WILEY RICH HUMPHREY
      JOHNS KOCH SUAREZ HOBBS BEARD GILMORE IBARRA KEITH MACIAS KHAN
      ANDRADE WARE STEPHENSON HENSON WILKERSON DYER MCCLURE BLACKWELL
      MERCADO TANNER EATON CLAY BARRON BEASLEY ONEAL PRESTON SMALL WU
      ZAMORA MACDONALD VANCE SNOW MCCLAIN STAFFORD OROZCO BARRY ENGLISH
      SHANNON KLINE JACOBSON WOODARD HUANG KEMP MOSLEY PRINCE MERRITT
      HURST VILLANUEVA ROACH NOLAN LAM YODER MCCULLOUGH LESTER SANTANA
      VALENZUELA WINTERS BARRERA LEACH ORR BERGER MCKEE STRONG CONWAY
      STEIN WHITEHEAD BULLOCK ESCOBAR KNOX MEADOWS SOLOMON VELEZ
      ODONNELL KERR STOUT BLANKENSHIP BROWNING KENT LOZANO BARTLETT
      PRUITT BUCK BARR GAINES DURHAM GENTRY MCINTYRE SLOAN MELENDEZ
      ROCHA HERMAN SEXTON MOON HENDRICKS RANGEL STARK LOWERY HARDIN HULL
      SELLERS ELLISON CALHOUN GILLESPIE MORA KNAPP MCCALL MORSE DORSEY
      WEEKS NIELSEN LIVINGSTON LEBLANC MCLEAN BRADSHAW GLASS MIDDLETON
      BUCKLEY SCHAEFER FROST HOWE HOUSE MCINTOSH HO PENNINGTON REILLY
      HEBERT MCFARLAND HICKMAN NOBLE SPEARS CONRAD ARIAS GALVAN
      VELAZQUEZ HUYNH FREDERICK RANDOLPH CANTU FITZPATRICK MAHONEY PECK
      VILLA MICHAEL DONOVAN MCCONNELL WALLS BOYLE MAYER ZUNIGA GILES
      PINEDA PACE HURLEY MAYS MCMILLAN CROSBY AYERS CASE BENTLEY SHEPARD
      EVERETT PUGH DAVID MCMAHON DUNLAP BENDER HAHN HARDING ACEVEDO
      RAYMOND BLACKBURN DUFFY LANDRY DOUGHERTY BAUTISTA SHAH POTTS
      ARROYO VALENTINE MEZA GOULD VAUGHAN FRY RUSH AVERY HERRING DODSON
      CLEMENTS SAMPSON TAPIA BEAN LYNN CRANE FARLEY CISNEROS BENTON
      ASHLEY MCKAY FINLEY BEST BLEVINS FRIEDMAN MOSES SOSA BLANCHARD
      HUBER FRYE KRUEGER BERNARD ROSARIO RUBIO MULLEN BENJAMIN HALEY
      CHUNG MOYER CHOI HORNE YU WOODWARD ALI NIXON HAYDEN RIVERS ESTES
      MCCARTY RICHMOND STUART MAYNARD BRANDT OCONNELL HANNA SANFORD
      SHEPPARD CHURCH BURCH LEVY RASMUSSEN COFFEY PONCE FAULKNER
      DONALDSON SCHMITT NOVAK COSTA MONTES BOOKER CORDOVA WALLER
      ARELLANO MADDOX MATA BONILLA STANTON COMPTON KAUFMAN DUDLEY
      MCPHERSON BELTRAN DICKSON MCCANN VILLEGAS PROCTOR HESTER CANTRELL
      DAUGHERTY CHERRY BRAY DAVILA ROWLAND LEVINE MADDEN SPENCE GOOD
      IRWIN WERNER KRAUSE PETTY WHITNEY BAIRD HOOPER POLLARD ZAVALA
      JARVIS HOLDEN HAAS HENDRIX MCGRATH BIRD LUCERO TERRELL RIGGS JOYCE
      MERCER ROLLINS GALLOWAY DUKE ODOM ANDERSEN DOWNS HATFIELD BENITEZ
      ARCHER HUERTA TRAVIS MCNEIL HINTON ZHANG HAYS MAYO FRITZ BRANCH
      MOONEY EWING RITTER ESPARZA FREY BRAUN GAY RIDDLE HANEY KAISER
      HOLDER CHANEY MCKNIGHT GAMBLE VANG COOLEY CARNEY COWAN FORBES
      FERRELL DAVIES BARAJAS SHEA OSBORN BRIGHT CUEVAS BOLTON MURILLO
      LUTZ DUARTE KIDD KEY COOKE GOFF DEJESUS MARIN DOTSON BONNER COTTON
      MERRILL LINDSAY LANCASTER) 

  STREET_NAMES = %w(Aspen Birch Cedar Dogwood Elm Ginkgo Hickory
      Ironwood Juniper Linden Maple Oak Palm Quince Redwood Spruce
      Tulip Willow)

  STREET_TYPES = %w(Avenue Boulevard Drive Place Road Street Way)

  CITIES = %w(Franklin Clinton Springfield Greenville Salem Fairview
      Madison Washington Georgetown Arlington Ashland Burlington
      Manchester Marion Oxford Clayton Jackson Milton Auburn Dayton
      Lexington Milford Riverside Cleveland Dover Hudson Kingston
      Mount\ Vernon Newport Oakland)

  STATES = %w(AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA
      ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PW PA RI SC
      SD TN TX UT VI VT VA WA WV WI WY)

  def pick(array, i)
    array[i % array.length]
  end

end

include SequenceHelpers

FactoryGirl.define do

  sequence :email do |n|
    "#{pick(FIRST_NAMES, n*373).downcase}.#{pick(LAST_NAMES, n*577).downcase}@example.com"
  end

  sequence :name do |n| 
    "#{pick(FIRST_NAMES, n*373)} #{pick(LAST_NAMES, n*577)}"
  end

  sequence :address do |n|
    # NB: length of street_name, street_type, city, state arrays are
    # all chosen to be relatively prime.
    street_number = 1000 + n
    street_name = pick(STREET_NAMES, n)
    street_type = pick(STREET_TYPES, n)
    city = pick(CITIES, n)
    state = pick(STATES, n)
    zip = sprintf("%05d", (1073676287 * (n + 1)) % 100000)
    "#{street_number} #{street_name} #{street_type}, #{city} #{state} #{zip}, USA"
  end
  
end
