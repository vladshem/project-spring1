package com.service;

import com.domain.Status;
import com.domain.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.repository.TaskRepository;
import org.springframework.util.StringUtils;

import java.util.Date;
import java.util.List;

import static java.util.Objects.isNull;
import static java.util.Objects.nonNull;

@Service
public class TaskService {

    @Autowired
    TaskRepository taskRepository;

    public List<Task> getAll(int pageNumber, int pageSize) {

        Pageable pageable = PageRequest.of(pageNumber, pageSize);
        return taskRepository.getAll(pageable);
    }

    public Integer getAllCount() {
        return taskRepository.getAllCount();
    }

    public Task createTask(String description, Status status) {
        Task task = new Task();
        task.setDescription(description);
        task.setStatus(status);

        return taskRepository.save(task);
    }

    public Task getTask(long id) {
        return taskRepository.findById(id).orElse(null);
    }

    public Task updateTask(long id, String description, Status status) {

        Task task = taskRepository.findById(id).orElse(null);
        if (isNull(task)) return null;

        boolean needUpdate = false;

        if (nonNull(description)) {
            task.setDescription(description);
            needUpdate = true;
        }
        if (nonNull(status)) {
            task.setStatus(status);
            needUpdate = true;
        }

        if (needUpdate) {
            taskRepository.save(task);
        }

        return task;
    }

    public Task delete(long id) {
        Task task = taskRepository.findById(id).orElse(null);
        if (isNull(task)) return null;

        taskRepository.delete(task);
        return task;
    }


}
