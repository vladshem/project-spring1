package com.controller;

import com.dto.TaskDTO;
import com.domain.Task;
import com.service.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

import static java.util.Objects.isNull;
import static java.util.Objects.nonNull;

@RestController
@RequestMapping("/rest/tasks")
public class TaskController {

    @Autowired
    TaskService taskService;

    @GetMapping()
    public List<TaskDTO> getAll(@RequestParam(required = false) Integer pageNumber,
                                @RequestParam(required = false) Integer pageSize) {
        pageNumber = isNull(pageNumber) ? 0 : pageNumber;
        pageSize = isNull(pageSize) ? 3 : pageSize;

        List<Task> tasks = taskService.getAll(pageNumber, pageSize);
        return tasks.stream().map(TaskController::toTaskDTO).collect(Collectors.toList());
    }

    @GetMapping("/count")
    public Integer getAllCount() {

        return taskService.getAllCount();
    }

    @PostMapping
    public ResponseEntity<TaskDTO> createTask(@RequestBody TaskDTO taskDTO) {
        if (isNull(taskDTO.description)) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        if (isNull(taskDTO.status)) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);

        Task task = taskService.createTask(taskDTO.description, taskDTO.status);
        return ResponseEntity.status(HttpStatus.OK).body(toTaskDTO(task));
    }

    @GetMapping("/{ID}")
    public ResponseEntity<TaskDTO> getTask(@PathVariable("ID") long id) {
        if (id <= 0) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);

        Task task = taskService.getTask(id);
        if (isNull(task)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(toTaskDTO(task));
        }
    }

    @PostMapping("/{ID}")
    public ResponseEntity<TaskDTO> updateTask(@PathVariable("ID") long id,
                                              @RequestBody TaskDTO taskDTO) {
        if (id <= 0) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        if (isNull(taskDTO.description)) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        if (isNull(taskDTO.status)) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);

        Task task = taskService.updateTask(id, taskDTO.description, taskDTO.status);

        if (isNull(task)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(toTaskDTO(task));
        }
    }

    @DeleteMapping("/{ID}")
    public ResponseEntity delete(@PathVariable("ID") long id) {
        if (id <= 0) return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);

        Task task = taskService.delete(id);
        if (isNull(task)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(null);
        }
    }

    private static TaskDTO toTaskDTO(Task task) {
        if (isNull(task)) return null;

        TaskDTO result = new TaskDTO();
        result.id = task.getId();
        result.description = task.getDescription();
        result.status = task.getStatus();

        return result;
    }

}
