using TaskManagerApi.Models; 

namespace TaskManagerApi.Repositories; 
public interface ITaskRepository { 
    IEnumerable<TaskItem> GetAll(); 
    TaskItem? GetById(int id); 
    TaskItem Create(TaskItem task); 
    bool Update(int id, TaskItem updatedTask); 
    bool Delete(int id); 
    
    }