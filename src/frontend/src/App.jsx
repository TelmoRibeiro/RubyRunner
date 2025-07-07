import { useState } from 'react'

function App() {
  const [distance,   setDistance]  = useState(0);
  const [start_time, setStartTime] = useState('');
  const [end_time,   setEndTime]   = useState('');
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

  const handlePostSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const response = await fetch('http://localhost:4567/add_run', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          distance:   distance,
          start_time: start_time,
          end_time:   end_time,
          date:       date,
          location:   location,
        })
      });
      if (!response.ok) {
        const errorMessage = await response.json();
        throw new Error(errorMessage.message || 'Could not resolve the error message: ' + response.status);
      }
      // @ telmo - dumping data
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
      set
    }
  };

  return (
    <div style={{ padding: '10rem', fontFamily: 'Arial' }}>
      <h1>Ruby Runner</h1>

      <form onSubmit={handleGetSubmit}>
        <label style={{ marginRight:'1rem' }}>Distance</label>
        <input
          type='text'
          placeholder='location'
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          required
        />
        <label style={{ marginLeft:'1rem', marginRight:'1rem' }}>Date</label>
        <input
          type='date'
          value={date}
          onChange={(e) => setDate(e.target.value)}
          required
        />
        <button type='submit' style={{ marginLeft:'1rem' }}>Check Run</button>
      </form>

      <form onSubmit={handlePostSubmit}>
        <label style={{ marginRight:'1rem' }}>Distance</label>
        <input
          type='number'
          step='0.01'
          value={distance}
          onChange={(e) => setDistance(e.target.value)}
          required
        />
        <label style={{ marginLeft:'1rem', marginRight:'1rem' }}>Start Time</label>
        <input
          aria-label='Start Time'
          type='time'
          value={start_time}
          onChange={(e) => setStartTime(e.target.value)}
          required
        />
        <label style={{ marginLeft:'1rem', marginRight:'1rem' }}>End Time</label>
        <input
          aria-label='End Time'
          type='time'
          value={end_time}
          onChange={(e) => setEndTime(e.target.value)}
          required
        />
        <label style={{ marginLeft:'1rem', marginRight:'1rem' }}>Date</label>
        <input
          aria-label='Date'
          type='date'
          max={new Date().toISOString().split('T')[0]}
          value={date}
          onChange={(e) => setDate(e.target.value)}
          required
        />
        <label style={{ marginLeft:'1rem', marginRight:'1rem' }}>Location</label>
        <input
          aria-label='Location'
          type='text'
          placeholder='location'
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          required
        />
        <button type='submit' style={{ marginLeft:'1rem' }}>Add Run</button>
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
