import React, { useEffect, useState } from 'react'
import axios from 'axios'
const Home = () => {
    const [tab, setTab] = useState(1)
    const [task, setTask] = useState('')
    const [todos, setTodos] = useState(null)
    const [isEdit, setIsEdit] = useState(false);

    const [activeTodos, setActiveTodos] = useState(null)
    const [completedTodos, setCompletedTodos] = useState(null)

    const handleTabs = (tab) => {
        setTab(tab)
        
    }

    const handleAddTask = (e) => {
        e.preventDefault();
        axios.post('api/new-task', {task})
        .then(res => {
            setTodos(res.data)
            setTask('')
        });
        
    }

    useEffect(() => {
        axios.get('api/read-tasks')
        .then(res => {
            setTodos(res.data)
            
        })
    }, [])

    

    const [updateId, setUpdateId] = useState(null)
    const [updatedTask, setUpdatedTask] = useState('')
    const handleEdit = (id, task) => {
        setIsEdit(true)
        setTask(task)
        setUpdatedTask(task);
        setUpdateId(id)

    }

    const updateTask = () => {
        axios.post('api/update-task', {updateId, task})
        .then(res => {
            setTodos(res.data)
            setTask('')
            setIsEdit(false)
        })

    }

    const handleDelete = (id) => {
        axios.post('api/delete-task', {id})
        .then(res => {
            setTodos(res.data)
        })
        
    }

    const handleComplete = (id) => {
        axios.post('api/complete-task', {id})
        .then(res => {
            setTodos(res.data)
        })
    }

    

  return (
    <div className=' bg-gray-screen w-screen h-screen'>
        <div className=' flex flex-col w-screen h-screen justify-center items-center'>
            <div>
                <h2 className=' font-bold text-2xl mb-4'>Todo Tasks</h2>
            </div>
            <div className=' flex gap-3'>
                <input value={task} onChange={e => setTask(e.target.value)} type='text' placeholder="Enter task" className=' w-64 p-2 outline-none border border-blue-300 rounded-md' />
                <button  className=' bg-green-600 text-white px-4 rounded-md'>{isEdit ? <button onClick={updateTask}>Update</button> : <button onClick={handleAddTask}>Add Task</button>}</button>
            </div>

            <div className=' flex text-sm w-80 justify-evenly mt-4'>
                <p onClick={() => handleTabs(1)} className={`${tab === 1 ? 'text-blue-700' : 'text-black'} cursor-pointer`}>All</p>
                <p onClick={() => handleTabs(2)} className={`${tab === 2 ? 'text-blue-700' : 'text-black'} cursor-pointer`}>Active</p>
                <p onClick={() => handleTabs(3)} className={`${tab === 3 ? 'text-blue-700' : 'text-black'} cursor-pointer`}>Done</p>
            </div>

            {
                tab == 1 && todos?.map(todo => (
                    <div className=' flex justify-between bg-white p-3 w-80 mt-3 rounded-md'>
                        <div>
                            <p className=' text-lg font-semibold'>{todo?.task}</p>
                                <p className=' text-xs text-gray-600'>{new Date(todo.createdOn).toLocaleDateString()}</p>
                                <p className=' text-sm text-gray-700'>Status : {todo.status}</p>
                        </div>

                        <div className=' flex flex-col text-sm justify-center items-start'>
                            {todo.status == 'completed' ? null : <button className=' text-blue-600 cursor-pointer' onClick={() => handleEdit(todo.id, todo.task)}>Edit</button>}
                            <button className=' text-red-500 cursor-pointer' onClick={() => handleDelete(todo.id)}>Delete</button>
                            {todo.status == 'completed' ? null : <button className=' text-green-600 cursor-pointer' onClick={() => handleComplete(todo.id)}>Done</button>}

                        </div>
                    </div>
                ))
            }

            {
                tab == 2 && todos?.filter(todo => todo.status == 'active').map(todo => (
                    <div className=' flex justify-between bg-white p-3 w-80 mt-3 rounded-md'>
                        <div>
                            <p className=' text-lg font-semibold'>{todo?.task}</p>
                                <p className=' text-xs text-gray-600'>{new Date(todo.createdOn).toLocaleDateString()}</p>
                                <p className=' text-sm text-gray-700'>Status : {todo.status}</p>
                        </div>

                        <div className=' flex flex-col text-sm justify-start items-start'>
                            {todo.status == 'completed' ? null : <button className=' text-blue-600 cursor-pointer' onClick={() => handleEdit(todo.id, todo.task)}>Edit</button>}
                            <button className=' text-red-500 cursor-pointer' onClick={() => handleDelete(todo.id)}>Delete</button>
                            {todo.status == 'completed' ? null : <button className=' text-green-600 cursor-pointer' onClick={() => handleComplete(todo.id)}>Done</button>}

                        </div>
                    </div>
                ))
            }

            {
                tab == 3 && todos?.filter(todo => todo.status == 'completed').map(todo => (
                    <div className=' flex justify-between bg-white p-3 w-80 mt-3 rounded-md'>
                        <div>
                            <p className=' text-lg font-semibold'>{todo?.task}</p>
                                <p className=' text-xs text-gray-600'>{new Date(todo.createdOn).toLocaleDateString()}</p>
                                <p className=' text-sm text-gray-700'>Status : {todo.status}</p>
                        </div>

                        <div className=' flex flex-col text-sm justify-center items-center'>
                            <button className=' text-red-500 cursor-pointer' onClick={() => handleDelete(todo.id)}>Delete</button>
                        </div>
                    </div>
                ))
            }

            
        </div>
    </div>
  )
}

export default Home