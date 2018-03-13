
from flask import Flask
#from flask import request
from flask_restful import Resource, Api
#from sqlalchemy import create_engine
#from json import dumps
from flask.ext.jsonpify import jsonify
import pyodbc
from nltk.corpus import stopwords
from nltk.stem.lancaster import LancasterStemmer
import re
import wikipedia
import sys
import os
sys.path.append(os.path.abspath("B:\\Capstone Project\\UI"))
import ChatBot as CB
from ChatBot import entity
from flask_cors import CORS

conn = pyodbc.connect("Driver={SQL Server Native Client 11.0}; Server=DESKTOP-UDAY-DE\SQLEXPRESS; Database=CourseCart; Trusted_Connection=yes;")

def findWords(inpString):
    listWords = inpString.split();
    for (index,w) in enumerate(listWords):
        word = re.sub('[\[\]\'\(\)\\/<>]','',w.lower())
        # skip large words as they might not be valid words
        if len(word) > 20:
            continue
        listWords[index] = word
    return list(set(listWords));

def removeStopWords(listWords):
    stop_words = set(stopwords.words('english'))
    listWordsWOStopWords = []
    for w in listWords:
        if not w.lower() in stop_words:
            listWordsWOStopWords.append(w.lower())
    return listWordsWOStopWords

def stemWords(listWords):
    stemmer = LancasterStemmer()
    listStemmedWords = []
    for w in listWords:
        stemmedWord = stemmer.stem(w)
        listStemmedWords.append(stemmedWord)
    return list(set(listStemmedWords))

class Course():
    CourseId = 0
    CourseName = ""
    Program = ""
    University = ""
    Rank = 0
    CountryCode = ""
    City = ""
    Deadline = ""
    Duration = ""
    TutionCcyCode = ""
    TutionFeeAmt = 0
    StartDate = ""
    IELTSCode = 0
    Structure = ""
    AcadReq = ""
    URL = ""

class SearchCourse(Resource):
    def get(self, searchText):
        #Stem the searchWords and join using space character
        listWords = findWords(searchText)
        listWords = removeStopWords(listWords)
        listWords = stemWords(listWords)
        spaceDelimitedSearchText = ''
        for w in listWords:
            spaceDelimitedSearchText = spaceDelimitedSearchText + ' ' + w
        numCourses = 6
        cursor = conn.cursor()
        cursor.execute("execute dbo.spGetMatchingCourses @StemmedSearchText = ?, @SplitChar = ?, @numCourses = ?", spaceDelimitedSearchText , ' ', str(numCourses))
        courseRows = cursor.fetchall()
        cursor.close()
        courses = []
        for courseRowData in courseRows:
            course = {}
            course["CourseId"] = courseRowData[0]
            course["CourseName"] = courseRowData[1].strip()
            course["Program"] = courseRowData[2].strip()
            course["University"] = courseRowData[3].strip()
            course["CountryName"] = courseRowData[4].strip()
            courses.append(course)
        result = {'matchingCourses': courses}
        return jsonify(result)

def getCourseDetails(courseId):
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetCourseDetails @CourseId = " + courseId)
    courseRow = cursor.fetchall()
    cursor.close()
    courseRowData = courseRow.pop(0)
    course = {}
    course["CourseId"] = courseId
    course["CourseName"] = courseRowData[1].strip()
    course["Program"] = courseRowData[2].strip()
    course["University"] = courseRowData[3].strip()
    course["Rank"] = courseRowData[4]
    course["CountryCode"] = courseRowData[5].strip()
    course["City"] = courseRowData[6].strip()
    course["Duration"] = courseRowData[8].strip()
    course["Deadline"] = courseRowData[7]
    course["TutionCcyCode"] = courseRowData[9].strip()
    course["TutionFeeAmt"] = courseRowData[10]
    course["StartDate"] = courseRowData[11]
    course["IELTSCode"] = courseRowData[12]
    course["Structure"] = courseRowData[13].strip()
    course["AcadReqs"] = courseRowData[14].strip()
    course["URL"] = courseRowData[15].strip()
    return course

def getSimilarCourses(courseId):
    numCourses = 6
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetSimilarCourses @CourseId = ?, @numCourses = ?", courseId, numCourses)
    courseRows = cursor.fetchall()
    cursor.close()
    courses = []
    for courseRowData in courseRows:
        course = {}
        course["CourseId"] = courseRowData[0]
        course["CourseName"] = courseRowData[1].strip()
        course["Program"] = courseRowData[2].strip()
        course["University"] = courseRowData[3].strip()
        course["CountryName"] = courseRowData[4].strip()
        courses.append(course)
    return courses

def getPreRequisites(courseId):
    numCourses = 6
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetCoursePreReqs @CourseId = ?, @numPreReqs = ?", courseId, numCourses)
    courseRows = cursor.fetchall()
    cursor.close()
    prereq_courses = []
    for courseRowData in courseRows:
        course = {}
        course["CourseId"] = courseRowData[0]
        course["CourseName"] = courseRowData[1].strip()
        course["Program"] = courseRowData[2].strip()
        course["University"] = courseRowData[3].strip()
        course["CountryName"] = courseRowData[4].strip()
        prereq_courses.append(course)
    return prereq_courses

def getFuturePath(courseId):
    numCourses = 6
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetCourseFuturePath @CourseId = ?, @numFuturePath = ?", courseId, numCourses)
    courseRows = cursor.fetchall()
    cursor.close()
    futurepath_courses = []
    for courseRowData in courseRows:
        course = {}
        course["CourseId"] = courseRowData[0]
        course["CourseName"] = courseRowData[1].strip()
        course["Program"] = courseRowData[2].strip()
        course["University"] = courseRowData[3].strip()
        course["CountryName"] = courseRowData[4].strip()
        futurepath_courses.append(course)
    return futurepath_courses

class ViewCourseDetails(Resource):
    def get(self, courseId):
        course = getCourseDetails(courseId)
        similar_courses = getSimilarCourses(courseId)
        prereq_courses = getPreRequisites(courseId)
        futurepath_courses = getFuturePath(courseId)
        wiki_search_text = course["Program"] + " " + course["CourseName"]
        wiki_content = ""
        try:
            wiki_content = wikipedia.summary(wiki_search_text)
        except:
            wiki_content = ""
        result = {'courseDetails': course,
                  'similarCourses': similar_courses,
                  'preRequisites': prereq_courses,
                  'futurePath': futurepath_courses,
                  'wikiContent': wiki_content
                  }
        return jsonify(result)

class Chatbot(Resource):
    def get(self, utterance):
        replyMessage = ""
        courses = []
        #course = None
        #preRequisites = []
        #futurePath = []
        global entity
        lstIntents = CB.identifyIntents(utterance)
        lstIntentsSize = len(lstIntents)
        for intent in lstIntents:
            if intent.intentType == 'greeting':
                replyMessage = intent.response
            elif intent.intentType == 'search':
                replyMessage = intent.response
                CB.findEntities(utterance)
                courses = CB.findCourses(utterance)
                resultSize = len(courses)
                if resultSize > 50:
                    replyMessage = "I found " + str(resultSize) + " courses matching your search."
                    replyMessage = replyMessage + "\nTell me the program names or types or location or university you want to look for."
                    replyMessage = replyMessage + "\nWe can narrow down the list further."
                    replyMessage = replyMessage + "\n*** You dont want me to dump so many on you ;)! ***"
                else:
                    #replyMessage = "I found "+str(resultSize)+" courses matching your search. Do you want to view them or filter them further?"
                    replyMessage = "I found "+str(resultSize)+" courses matching your search."
            elif intent.intentType == 'view':
                replyMessage = intent.response
                courses = CB.findCourses(utterance)
                #displayResults()
                #printCourses()
            elif intent.intentType == 'stop':
                # Check if stop is the only intent, else do not stop the chat here.
                if (lstIntentsSize == 1):
                    replyMessage = intent.response
            elif intent.intentType == 'restart':
                replyMessage = intent.response
                CB.clearEntities()
            elif intent.intentType == 'showstructure':
                print ("\n")
                replyMessage = intent.response
                entity.showstructure = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showfees':
                replyMessage = intent.response
                entity.showfees = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showrank':
                replyMessage = intent.response
                entity.showrank = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showlocation':
                replyMessage = intent.response
                entity.showcity = True
                entity.showcountry = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showduration':
                replyMessage = intent.response
                entity.showduration = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showdate':
                replyMessage = intent.response
                entity.showdate = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showacadreqs':
                replyMessage = intent.response
                entity.showacadreqs = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showuniv':
                replyMessage = intent.response
                entity.showuniv = True
                courses = CB.findCourses(utterance)
                #CB.printCourses()
            elif intent.intentType == 'showdebug':
                replyMessage = intent.response
                #showdebug = True
            else:
                replyMessage = "I cant understand your intent :(! Please have a human communicate with me!"
        result={"replyMessage":replyMessage, "courses":courses}
        return jsonify(result)

def getTopRatedCourses():
    numCourses = 6
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetTopRatedCourses @numCourses = ?", numCourses)
    courseRows = cursor.fetchall()
    cursor.close()
    courses = []
    for courseRowData in courseRows:
        course = {}
        course["CourseId"] = courseRowData[0]
        course["CourseName"] = courseRowData[1].strip()
        course["Program"] = courseRowData[2].strip()
        course["University"] = courseRowData[3].strip()
        course["CountryName"] = courseRowData[4].strip()
        courses.append(course)
    return courses

def getTrendingCourses():
    numCourses = 6
    cursor = conn.cursor()
    cursor.execute("execute dbo.spGetTrendingCourses @numCourses = ?", numCourses)
    courseRows = cursor.fetchall()
    cursor.close()
    courses = []
    for courseRowData in courseRows:
        course = {}
        course["CourseId"] = courseRowData[0]
        course["CourseName"] = courseRowData[1].strip()
        course["Program"] = courseRowData[2].strip()
        course["University"] = courseRowData[3].strip()
        course["CountryName"] = courseRowData[4].strip()
        courses.append(course)
    return courses

class ViewTrendingAndTopRatedCourses(Resource):
    def get(self):
        topRatedCourses = getTopRatedCourses()
        trendingCourses = getTrendingCourses()
        result = {'trendingCourses': trendingCourses,
                  'topRatedCourses': topRatedCourses,
                 }
        return jsonify(result)

app = Flask(__name__)
cors = CORS(app)
api = Api(app)

api.add_resource(ViewTrendingAndTopRatedCourses, '/viewTrendingAndTopRatedCourses/')
api.add_resource(SearchCourse, '/searchCourse/<searchText>')
api.add_resource(ViewCourseDetails, '/viewCourseDetails/<courseId>')
api.add_resource(Chatbot, '/processChatbotInput/<utterance>')

if __name__ == '__main__':
     app.run(port=5002)
