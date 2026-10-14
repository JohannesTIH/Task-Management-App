using TaskManagerApi.Models; 

namespace TaskManagerApi.Repositories; 

public class InMemoryTaskRepository : ITaskRepository 

{ 

    private readonly List<TaskItem> _tasks = new(); 

    private int _nextId = 1; 



    public IEnumerable<TaskItem> GetAll() 

    { 

        return _tasks; 

    } 

 

    public TaskItem? GetById(int id) 

    { 

        return _tasks.FirstOrDefault(t => t.Id == id); 

    } 

 

    public TaskItem Create(TaskItem task) 

    { 

        task.Id = _nextId++; 

        if (string.IsNullOrEmpty(task.Category))
        {
            task.Category = "Personal";
        }

        task.CreatedAt = DateTime.UtcNow; 

        _tasks.Add(task); 

        return task; 

    } 

 

    public bool Update(int id, TaskItem updatedTask) 

    { 

        var existingTask = GetById(id); 

        if (existingTask == null) return false; 

 

        existingTask.Title = updatedTask.Title; 

        existingTask.Description = updatedTask.Description; 

        existingTask.IsCompleted = updatedTask.IsCompleted; 

        existingTask.Priority = updatedTask.Priority; 

        if (!string.IsNullOrEmpty(updatedTask.Category))
        {
            existingTask.Category = updatedTask.Category;
        }

        existingTask.DueDate = updatedTask.DueDate; 

 

        return true; 

    } 

 

    public bool Delete(int id) 

    { 

        var task = GetById(id); 

        if (task == null) return false; 

 

        _tasks.Remove(task); 

        return true; 

    } 

}
