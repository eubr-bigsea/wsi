#!/usr/bin/python

import argparse
import logging
import os
import pip
import requests
import shlex
import shutil
import subprocess
import sys
import time
import xml.etree.ElementTree

#Install required packages
try:
    import docker
except:
    pip.main(['install', 'docker-py'])
    import docker

try:
    import mysql.connector
except:
    pip.main(['install', 'mysql-connector==2.1.4'])
    import mysql.connector


#Connect to docker daemon
cli = docker.from_env()

parser = argparse.ArgumentParser(description="Collect OPT_IC data")
parser.add_argument('-a', "--app", help="The application")
parser.add_argument('-d', "--dataset", help="The dataset size")
parser.add_argument('-c', "--cores", help="The number of cores")
parser.add_argument('-s', "--stage", help="The stage")
parser.add_argument('-p', "--points", help="Percentages of the deadline to be evaluated", default="0.25, 0.5, 0.75, 0.99, 1.00, 1.5, 2.0")

#The absolute path of current script
abs_script = os.path.abspath(sys.argv[0])
working_directory = os.getcwd()
temporary_directory = os.path.join(working_directory, "tmp_opt_ic")
abs_path = os.path.dirname(abs_script)

#Create temporary directory
if os.path.exists(temporary_directory):
    shutil.rmtree(temporary_directory)
os.mkdir(temporary_directory)

#Parse arguments
args = parser.parse_args()

#Initialize logging
logging.basicConfig(level=logging.INFO,format='%(levelname)s: %(message)s')

#Check app
if not args.app:
    logging.error("Application not set")
    sys.exit(1)

#Check dataset
if not args.dataset:
    logging.error("Dataset not set")
    sys.exit(1)

#Check cores
if not args.cores:
    logging.error("Cores not set")
    sys.exit(1)

#Check stage
if not args.stage:
    logging.error("Stage not set")
    sys.exit(1)

#The name of the generated results file
results_file_name = args.app + "_" + args.dataset + "_" + args.stage + "_" + args.cores + ".txt"
results_file = open(results_file_name, "w")

#If the results file exists, remove it
if os.path.exists(results_file_name):
    os.remove(results_file_name)


#Get the address of the wsi docker
wsi_address = cli.inspect_container("wsi_service")["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
logging.info("WSI ip address is " + wsi_address)

#Get the address of the mysql docker
mysql_address = cli.inspect_container("mysql_bigsea")["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
logging.info("MYSQL ip address is " + mysql_address)

#Restart the mysql docker
cli.stop("mysql_bigsea")
cli.start("mysql_bigsea")

#Wait 5 seconds for starting of mysql start
logging.info("Sleeping 5 seconds")
time.sleep(5)

#Get mysql password
exec_instance = cli.exec_create(container="wsi_service", cmd="cat wsi_config.xml")
xml_string = cli.exec_start(exec_id=exec_instance, stream=True).next()
root_xml = xml.etree.ElementTree.fromstring(xml_string)
mysql_password = root_xml.findall("./entry[@key='DB_pass']")[0].text
logging.info("xml_string is " + str(mysql_password))

#Connect to mysql
cnx = mysql.connector.connect(user='bigsea', password=mysql_password, host=mysql_address, database='bigsea')
cnx.autocommit = True
cursor = cnx.cursor(buffered=True)

#Clean databases
command = os.path.join(abs_path, "clean_DB.sh")
logging.info("Executing " + command)
subprocess.call(command, shell=True)

#Insert profile data
cursor.execute(file(os.path.join(abs_path, "Database/insertFakeProfile.sql")).read())

#Call dagsim to get the overall execution time
get_request = "http://" + wsi_address + ":8080/bigsea/rest/ws/dagsimR/" + args.cores + "/8G/" + args.dataset + "/" + args.app
logging.info("Get request is : " + get_request)
deadline = requests.get(get_request).text
logging.info("Result of dagsim " + str(deadline))

#Add submission of application
add_running_application = ("INSERT INTO RUNNING_APPLICATION_TABLE" "(application_session_id, application_id, dataset_size, submission_time, status, weight, deadline, num_cores)" "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)")
running_application_data = ('application_1483347394756_5', args.app, args.dataset, '2017-01-01 00:00:00', 'RUNNING', '1', deadline, args.cores);
cursor.execute(add_running_application, running_application_data)

#Initialize data structure
new_data_example_file= open(os.path.join(temporary_directory, "new_data_example.txt"), "w")
new_data_example_file.write(args.app + "\n")
new_data_example_file.write(args.dataset + "\n")
new_data_example_file.write(str((long(args.cores)/2)) + "\n")
new_data_example_file.write(str((long(deadline)*2)) + "\n")
new_data_example_file.write(str((long(args.cores)*2)) + "\n")
new_data_example_file.write(str((long(deadline)/2)) + "\n")
new_data_example_file.write("1s\n")
new_data_example_file.write(mysql_password + "\n")
new_data_example_file.flush()
new_data_example_file.close()
command = "cat " + new_data_example_file.name + " | " + abs_path + "/insert_new_data.sh"
logging.info("Executing " + command)
subprocess.call(command, shell=True)

#Wait for initialization of open data structure
while(1):
    query = ("SELECT * FROM OPTIMIZER_CONFIGURATION_TABLE")
    cursor.execute(query)
    data = cursor.fetchall()
    if(len(data) == 3):
        logging.info("Initialization ended")
        break
    logging.info("Content of OPTIMIZER_CONFIGURATION_TABLE: " + str(data))
    time.sleep(60)

#Query database to retrieve end time of stage
query = ("SELECT val FROM PREDICTOR_CACHE_TABLE where application_id =\"" + args.app + "\" and stage = \"" + args.stage + "\" and is_residual = 0")
logging.info("Query is " + query)
cursor.execute(query)
data = cursor.fetchall()
if(len(data) != 1):
    logging.error("Error in PREDICTOR_CACHE_TABLE")
    sys.exit(1)

stage_end_time = data[0][0]
logging.info("End time of stage is " + str(stage_end_time))

remaining_time = long(deadline) - long(stage_end_time)
submission_time = 1483228800000

zero_elapsed_time = False

#Evaluate points
points_to_be_evaluated = args.points.split(",")
for point in points_to_be_evaluated:
    logging.info("Evaluating point " + point)
    elapsed_time_from_submission = long(deadline) - long(float(remaining_time) * float(point))
    if(elapsed_time_from_submission < 0):
        logging.info("Elapsed time would be negative")
        continue
    elapsed_time = submission_time + elapsed_time_from_submission
    get_request = "http://" + wsi_address + ":8080/bigsea/rest/ws/resopt/application_1483347394756_5/" + args.dataset + "/" + deadline + "/" + args.stage + "/" + str(elapsed_time)
    logging.info("Get request is : " + get_request)
    result = requests.get(get_request).text
    logging.info("Result is " + result)
    if(len(result.split(" ")) != 3):
        logging.error("Unexpected pattern in OPT_IC result")
        sys.exit(1)
    rescaled_deadline = result.split(" ")[2]
    #Wait for end of OPT_IC
    while(1):
        query = ("SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE where application_id = \"" + args.app + "\" and dataset_size = " + args.dataset + " and deadline = " + rescaled_deadline)
        logging.info("Query is " + query)
        cursor.execute(query)
        data = cursor.fetchall()
        if(len(data) == 1):
            logging.info("OPT_IC execution ended. Result is " + str(data[0][0]))
            results_file.write(str(point) + ", " + str(rescaled_deadline) + ", " + str(data[0][0]) + "\n")
            break
        time.sleep(60)
    if(zero_elapsed_time):
        break

#Close results file
results_file.close()

#Close connection to mysql
cursor.close()
cnx.close()

