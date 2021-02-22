
class QuizBrain {
 static int _questionNumber = 0;
  static List<Question> _questions = [

  ];

  void addQuestion(Question item){
    _questions.add(item);
  }
  void setQuestionNumber(number){
    _questionNumber = number;
  }
 String getQImgUrl(){
   return _questions[_questionNumber].qImgUrl;
 }
 String getCImgUrl(){
   return _questions[_questionNumber].cImgUrl;
 }
 bool getQuestionImageStatus(){
   return _questions[_questionNumber].questionImg;
 }
  void nextQuestion(){
    _questionNumber++;
  }
  String getQuestionText(){
    return _questions[_questionNumber].question;
  }
  String getQuestionOptions(){
    return _questions[_questionNumber].options;
  }
  String getHints(){
    return _questions[_questionNumber].hints;
  }
  String getQuestionAnswer(){
    return _questions[_questionNumber].answer;
  }
  String getCurosity(){
    return _questions[_questionNumber].curosity;
  }
  String getQuestionType(){
    return _questions[_questionNumber].type;
  }

  int getQuestionsLength(){
    return _questions.length;
  }
  int getQuestionsNumber(){
    return _questionNumber;
  }

void setEmpty(){
    _questions=[];
}
}


class Question {
  final String question;
final String options;
final String answer;
final String type;
final String curosity;
final String hints;
  final String qImgUrl;
  final String cImgUrl;
  final bool questionImg;


Question({this.question, this.options, this.answer, this.type,this.curosity,this.hints,this.qImgUrl,this.cImgUrl,this.questionImg});
}

