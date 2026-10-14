using Microsoft.AspNetCore.Mvc; 

using TaskManagerApi.Models; 

using TaskManagerApi.Repositories; 

namespace TaskManagerApi.Controllers; 

[ApiController] 

[Route("api/[controller]")] 

public class TasksController : ControllerBase 

{ 

    private readonly ITaskRepository _repository; 

 

    public TasksController(ITaskRepository repository) 

    { 

        _repository = repository; //Dependency Injection

    } 

 

    // GET: api/tasks 

    [HttpGet] 

    public ActionResult<IEnumerable<TaskItem>> GetAll() 

    { 

        return Ok(_repository.GetAll()); 

    } 

 

    // GET: api/tasks/1 

    [HttpGet("{id:int}")] 

    public ActionResult<TaskItem> GetById(int id) 

    { 

        var task = _repository.GetById(id); 

        if (task == null) return NotFound(); 

 

        return Ok(task); 

    } 

 

    // POST: api/tasks 

    [HttpPost] 

    public ActionResult<TaskItem> Create(TaskItem task) 

    { 

        var createdTask = _repository.Create(task); 

        return CreatedAtAction(nameof(GetById), new { id = createdTask.Id }, createdTask); 

    } 

 

    // PUT: api/tasks/1 

    [HttpPut("{id:int}")] 

    public IActionResult Update(int id, TaskItem task) 

    { 

        var updated = _repository.Update(id, task); 

        if (!updated) return NotFound(); 

 

        return NoContent(); 

    } 

 

    // DELETE: api/tasks/1 

    [HttpDelete("{id:int}")] 

    public IActionResult Delete(int id) 

    { 

        var deleted = _repository.Delete(id); 

        if (!deleted) return NotFound(); 


        return NoContent(); 

    } 

} 