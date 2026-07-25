import React from 'react'
import './index.css'
import Home from './Home'
import Alert from './Alert'
import FlexBox from './FlexBox'
const App = () => {
  return (
    <div>
      <Home>
        <Alert>
        <FlexBox />
        </Alert>
      </Home>
    </div>
  )
}

export default App