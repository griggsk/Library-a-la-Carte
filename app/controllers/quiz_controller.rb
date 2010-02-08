class QuizController < ApplicationController
  skip_before_filter :authorize, :only =>[:grade_quiz, :practice_quiz, :retake_quiz, :view_quiz_results]
  before_filter :student_authorize, :only =>[:grade_quiz, :view_quiz_results]
  before_filter :module_types, :except =>[:grade_quiz, :practice_quiz, :retake_quiz]
  before_filter :current_page, :except =>[:grade_quiz, :practice_quiz, :retake_quiz]
  before_filter :current_guide, :except =>[:grade_quiz, :practice_quiz, :retake_quiz]
  before_filter :current_tutorial
  layout 'tool'

 def edit_quiz
     @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "QuizResource")
     rescue ActiveRecord::RecordNotFound
        redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
     else 
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
      @choices = [
     ["Multiple Choice",  "MC"],
     ["True/False",        "TF"],
     ["Free Write",       "FW"]
   ]
     end
end

 def update_quiz
   @mod = find_mod(params[:id], "QuizResource")
      @mod.update_attributes(params[:mod]) 
      if @mod.save 
          if params[:commit]=="Save & Add Question"
           redirect_to :action => 'edit_question', :id =>@mod and return
         else
          redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class and return
         end
      else 
        render :action => 'edit_question' , :mod => @mod
      end
 end
 
 
 def edit_question
  @mod = find_mod(params[:id], "QuizResource")
  @choices = [
     ["Multiple Choice",  "MC"],
     ["True/False",        "TF"],
     ["Free Write",       "FW"]
   ]
   @question = params[:qid] ? @mod.questions.find(params[:qid]) : Question.new
   @mod.questions << @question unless @mod.questions.include?(@question)
   if request.post?
      @question.update_attributes(params[:question]) 
      if @question.save 
          if params[:commit]=="Save & Add Answer"
           redirect_to :action => 'edit_answer', :id =>@mod, :qid => @question and return
         else
          redirect_to :action => 'edit_quiz', :id =>@mod.id and return
         end
      end
   end
 end  

 def edit_answer
  @mod = find_mod(params[:id], "QuizResource")
  @question = @mod.questions.find(params[:qid])
   @answer = params[:aid] ? @question.answers.find(params[:aid].to_i) : Answer.new
   if request.post?
      @question.answers << @answer unless @question.answers.include?(@answer)
      @answer.update_attributes(params[:answer]) 
      if @answer.save 
          if params[:commit]=="Save & Add Another Answer"
           redirect_to :action => 'edit_answer', :id =>@mod, :qid => @question and return
         else
          redirect_to :action => 'edit_quiz', :id =>@mod.id and return
         end
      end
   end
 end


 def remove_question
    @mod = find_mod(params[:id], "QuizResource")
    question = Question.find(params[:qid])
   if request.xhr?
   @mod.questions.destroy(question)
        render :update do |page|
          page.replace_html 'question_container', :partial => 'quiz/questions',  :collection =>@mod.questions.uniq
        end
    end
 end
 
  def remove_answer
    @mod = find_mod(params[:id], "QuizResource")
    @question = @mod.questions.find(params[:qid])
    answer = Answer.find(params[:aid])
   if request.xhr?
   @question.answers.destroy(answer)
        render :update do |page|
          page.replace_html 'answer_container'+@question.id.to_s, :partial => 'quiz/answers',  :locals => {:question => @question}
        end
    end
 end

def copy_quiz
    begin
     @old_mod = find_mod(params[:id], "QuizResource")
    rescue Exception 
     redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.global = false
     if @mod.save
       @mod.label =  @old_mod.label+'-copy'
        @mod.questions << @old_mod.questions
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
     end
   end  
 end

def sort_questions
  @mod = find_mod(params[:id], "QuizResource")
   if params['question_container'] then 
      sortables = params['question_container'] 
      sortables.each do |id|
        question = @mod.questions.find(id)
        question.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
   render :nothing => true 
end

def sort_answers
  @mod = find_mod(params[:id], "QuizResource")
  question = Question.find(params[:qid])
   if params['answer_container'+question.id.to_s] then 
      sortables = params['answer_container'+question.id.to_s] 
      sortables.each do |id|
        answer = question.answers.find(id)
        answer.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
   render :nothing => true 
end

def practice_quiz
  results=[]
   @mod = find_mod(params[:id], "QuizResource")
   @mod.questions.each do |question|
     if params[question.id.to_s]
       results << question.grade_answer(params[question.id.to_s])
     end
   end
   render :update do |page|
          page.replace_html 'quiz', :partial => 'quiz/answer_results',  :locals => {:mod => @mod, :results => results}
   end
end

def retake_quiz
   @mod = find_mod(params[:id], "QuizResource")
   render :update do |page|
          page.replace_html 'quiz', :partial => 'quiz/practice_quiz',  :locals => {:mod => @mod}
   end
end

def grade_quiz
  results=[]
   @mod = find_mod(params[:id], "QuizResource")
   @mod.questions.each do |question|
     if params[question.id.to_s]
       question.grade_answer(params[question.id.to_s], @student.id)
     end
   end
   results = @student.get_results(@mod.id)
   render :update do |page|
          page.replace_html 'quiz', :partial => 'quiz/answer_results',  :locals => {:mod => @mod, :results => results}
   end
end

def view_quiz_results
  results=[]
   @mod = find_mod(params[:id], "QuizResource")
   results = @student.get_results(@mod.id)
   render :update do |page|
          page.replace_html 'quiz', :partial => 'quiz/answer_results',  :locals => {:mod => @mod, :results => results}
   end
end

end
