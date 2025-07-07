import { useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
// import './App.css'

function App() {
  const [date,       setDate]      = useState('');
  const [location,   setLocation]  = useState('');
  const [records,    setRecords]   = useState([]);
  const [isLoading,  setIsLoading] = useState(false);
  const [error,      setError]     = useState('');

  const handleGetSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const parameters = new URLSearchParams({ date: date, location: location });
      const response = await fetch(`http://localhost:4567/check_run?${parameters}`);
      if (!response.ok) {
        const errorMessage = await response.json();
        throw new Error(errorMessage.error || 'Could not resolve the error message' + response.status);
      }
      const data = await response.json();
      setRecords(data);
    } catch (err) {
      setError(err.message);
      setRecords([]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ padding: '10rem', fontFamily: 'Arial' }}>
      <h1>Ruby Runner</h1>

      <form onSubmit={handleGetSubmit}>
        <input
          type='text'
          placeholder='location'
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          required
        />
        <input
          type='date'
          value={date}
          onChange={(e) => setDate(e.target.value)}
          required
        />
        <button type='submit'>Check Run</button>
      </form>

      { isLoading && <p style={{ color:'white' }}>'Loading...'</p> }

      { error && <p style={{ color: 'red' }}>{error}</p> }

      { records.length > 0 && (
        <>
          <h2>Table</h2>
          <table border='2'>
            <thead>
              <tr>
                <th>Distance</th>
                <th>Start Time</th>
                <th>End Time</th>
                <th>Duration</th>
                <th>Pace</th>
                <th>Date</th>
                <th>Location</th>
              </tr>
            </thead>
            <tbody>
              { records.map((record, index) => (
                <tr key={index}>
                  <td>{record.distance}</td>
                  <td>{record.start_time}</td>
                  <td>{record.end_time}</td>
                  <td>{record.duration}</td>
                  <td>{record.pace}</td>
                  <td>{record.date}</td>
                  <td>{record.location}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
    </div>
  );
}

export default App
