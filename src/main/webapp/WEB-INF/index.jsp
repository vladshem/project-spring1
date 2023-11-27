<html lang="en">
<head>
    <title>Task</title>
    <script src=https://code.jquery.com/jquery-3.6.0.min.js></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body onload="show_list(0)">
<h1>Task admin panel</h1>
<div class="d-inline-flex">
    <label for="select_count_1">Count per page:</label>
    <select id="select_count_1" class="form-select form-select-sm" aria-label="" style="width:auto" onchange="show_list(0)">
        <option value="3">3</option>
        <option value="5">5</option>
        <option value="10">10</option>
        <option value="20">20</option>
    </select>
</div>
<div>
    <table id="table_1" class="table table-hover table-bordered">
        <thead class="bg-light">
        <tr>
            <th scope="col">#</th>
            <th scope="col">Description</th>
            <th scope="col">Status</th>
        </tr>
        </thead>
        <tbody id="table_body_1">
        </tbody>
    </table>
    <div id="paging_buttons">Pages:</div>
    <hr>
    <h2>Create new task:</h2>
    <form>
        <div class="row mb-3 align-items-center">
            <div class="col-auto">
                <label for="input_description_new" class="form-label">Description:</label>
            </div>
            <div class="col-auto">
                <input type="text" id="input_description_new" class="form-control" placeholder="Description" required size="100" maxlength="100"/>
            </div>
        </div>
        <div class="row mb-3 align-items-center">
            <div class="col-auto">
                <label for="select_status_new" class="form-label">Status:</label>
            </div>
            <div class="col-auto">
                <select class="form-select" id="select_status_new">
                    <option value='IN_PROGRESS'>IN_PROGRESS</option>
                    <option value='DONE'>DONE</option>
                    <option value='PAUSED'>PAUSED</option>
                </select>
            </div>
        </div>
        <button type="button" class="btn btn-secondary btn-md" onclick="createTask()">Save</button>
    </form>

    <script>
        function show_list(page_number){
            $("tr:has(td)").remove();

            let url = GetBaseUrl() + "rest/tasks?";

            let counterPerPage = $("#select_count_1").val();
            if (counterPerPage == null) {
                counterPerPage = 3;
            }

            url = url.concat("pageSize=").concat(counterPerPage);

            if (page_number == null) {
                page_number = 0;
            }

            url = url.concat("&pageNumber=").concat(page_number);

            $.get(url, function (response) {
                $.each(response, function (i, item) {
                    $('<tr>').append(
                        $('<td>').text(item.id),
                        $('<td>').text(item.description),
                        $('<td>').text(item.status),
                        $('<td>').append(
                            $('<button>')
                                .attr("id", "button_edit_" + item.id)
                                .attr("type", "button")
                                .attr("onclick", "editTask(" + item.id + ")")
                                .addClass("btn")
                                .addClass("btn-outline-secondary")
                                .addClass("btn-lg")
                                .append(
                                    $('<i>')
                                        .addClass("bi")
                                        .addClass("bi-pencil"))),
                        $('<td>').append(
                            $('<button>')
                                .attr("id", "button_delete_" + item.id)
                                .attr("type", "button")
                                .attr("onclick", "deleteTask(" + item.id + ")")
                                .addClass("btn")
                                .addClass("btn-outline-secondary")
                                .addClass("btn-lg")
                                .append(
                                    $('<i>')
                                        .addClass("bi")
                                        .addClass("bi-trash3")))
                    ).appendTo('#table_body_1');
                });
            })
            let totalCount = GetTotalCount();
            let pageCount = Math.ceil(totalCount/counterPerPage);

            $("#paging_buttons button").remove();

            for(let i=0; i< pageCount; i++) {
                let button_tag = "<button>" + (i+1) + "</button>";
                let btn = $(button_tag)
                    .attr("id", "paging_button_" + i)
                    .attr("onclick", "show_list(" + i +")")
                    .attr("type", "button")
                    .addClass("btn")
                    .addClass("btn-outline-secondary")
                    .appendTo("#paging_buttons");
            }

            let identification = "#paging_button_" + page_number;
            $(identification)
                .attr("aria-pressed", true)
                .addClass("active");
        }

        function GetTotalCount() {
            let url = GetBaseUrl() + "rest/tasks/count";
            let res = 0;
            $.ajax({
                url: url,
                async: false,
                success: function (result) {
                    res = parseInt(result);
                }
            })
            return res;
        }

        function deleteTask(id) {
            let url = GetBaseUrl() + "rest/tasks/" + id;
            $.ajax({
                url: url,
                type: 'DELETE',
                async: false,
                success: function (result) {
                    show_list(getCurrentPage())
                }
            })

        }

        function getCurrentPage() {
            let current_page = 1;
            $('button:parent(div)').each(function () {
                if ($(this).attr("aria-pressed") === "true") {
                    current_page = $(this).text();
                }
            })
            return current_page - 1;
        }

        function editTask(id) {
            let identification_delete = "#button_delete_" + id;
            let identification_edit = "#button_edit_" + id;

            $(identification_delete).remove();
            $(identification_edit).html('<i class="bi bi-save"></i>');

            let current_tr_element = $(identification_edit).parent().parent();
            let children = current_tr_element.children();

            let td_description = children[1];
            td_description.innerHTML = "<input id='input_description_" + id + "' type='text' class='form-control' value='" + td_description.innerHTML + "'>";

            let td_status = children[2];
            let status_id = "#select_status_" + id;
            let status_current_value = td_status.innerHTML;
            td_status.innerHTML = getDropDawnStatusHtml(id);
            $(status_id).val(status_current_value).change();

            let property_save_tag = "saveTask(" + id + ")";
            $(identification_edit).attr("onclick", property_save_tag);
        }

        function getDropDawnStatusHtml(id) {
            let status_id = "select_status_" + id;
            return "<select id=" + status_id + " name='status' class='form-select'>" +
                "        <option value='IN_PROGRESS'>IN_PROGRESS</option>" +
                "        <option value='DONE'>DONE</option>" +
                "        <option value='PAUSED'>PAUSED</option>" +
                "    </select>";
        }

        function createTask() {
            let value_description = $("#input_description_new").val();
            let value_status = $("#select_status_new").val();

            let url = GetBaseUrl() + "rest/tasks";

            $.ajax({
                url: url,
                type: 'POST',
                dataType: "JSON",
                contentType: "application/json; charset=utf-8",
                async: false,
                data: JSON.stringify({
                    "description": value_description,
                    "status": value_status
                }),
                success: function (result) {
                    $("#input_description_new").val("");
                    $("#select_status_new").val("");
                    show_list(getCurrentPage(""))
                }
            })
        }

        function saveTask(id) {
            let value_description = $('#input_description_' + id).val();
            let value_status = $('#select_status_' + id).val();

            let url = GetBaseUrl() + "rest/tasks/" + id;

            $.ajax({
                url: url,
                type: 'POST',
                dataType: "JSON",
                contentType: "application/json; charset=utf-8",
                async: false,
                data: JSON.stringify({
                    "description": value_description,
                    "status": value_status
                }),
                success: function (result) {
                    show_list(getCurrentPage())
                }
            })

        }

        function GetBaseUrl() {
            let current_path = window.location.href;
            let end_position = current_path.indexOf('?');
            return current_path.substring(0, end_position);
        }
    </script>
</div>

</body>
</html>
