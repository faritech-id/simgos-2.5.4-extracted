# BPJS-SEP UI Modernization Plan

## Overview

This document outlines the plan to modernize the BPJS-SEP user interface using modern web technologies. The new UI will replace the existing ExtJS implementation with a React-based solution that provides better user experience, performance, and maintainability.

## Technology Stack

- **Frontend Framework**: React 18
- **UI Components**: Material-UI (MUI) v5
- **State Management**: Redux Toolkit
- **API Integration**: React Query
- **Form Handling**: React Hook Form
- **Type Safety**: TypeScript
- **Build Tool**: Vite
- **Testing**: Jest + React Testing Library
- **Styling**: Emotion (CSS-in-JS)

## Component Structure

```
src/
├── components/
│   ├── bpjs/
│   │   ├── BPJSLookup/
│   │   │   ├── index.tsx
│   │   │   ├── BPJSLookupForm.tsx
│   │   │   └── BPJSPatientCard.tsx
│   │   └── SEPManagement/
│   │       ├── index.tsx
│   │       ├── SEPForm.tsx
│   │       ├── SEPList.tsx
│   │       └── SEPDetails.tsx
│   ├── common/
│   │   ├── Layout/
│   │   ├── Navigation/
│   │   └── Forms/
│   └── shared/
│       ├── Button/
│       ├── Card/
│       └── Dialog/
├── features/
│   ├── bpjs/
│   │   ├── bpjsSlice.ts
│   │   └── bpjsAPI.ts
│   └── sep/
│       ├── sepSlice.ts
│       └── sepAPI.ts
└── pages/
    ├── BPJSVerification.tsx
    ├── SEPGeneration.tsx
    └── SEPManagement.tsx
```

## Key Features and Improvements

### 1. BPJS Patient Verification
```typescript
// src/components/bpjs/BPJSLookup/BPJSLookupForm.tsx
interface BPJSLookupFormProps {
  onVerificationSuccess: (patient: BPJSPatient) => void;
}

export const BPJSLookupForm: React.FC<BPJSLookupFormProps> = ({ onVerificationSuccess }) => {
  const { register, handleSubmit } = useForm<BPJSLookupFormData>();
  const verifyPatient = useMutation(verifyBPJSPatient);

  const onSubmit = async (data: BPJSLookupFormData) => {
    try {
      const result = await verifyPatient.mutateAsync(data);
      onVerificationSuccess(result.patient);
    } catch (error) {
      // Handle error
    }
  };

  return (
    <Card>
      <CardHeader title="BPJS Verification" />
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)}>
          <TextField
            {...register('bpjsNumber')}
            label="BPJS Number"
            fullWidth
            required
          />
          <TextField
            {...register('nik')}
            label="NIK"
            fullWidth
          />
          <LoadingButton
            loading={verifyPatient.isLoading}
            type="submit"
            variant="contained"
            fullWidth
          >
            Verify Patient
          </LoadingButton>
        </form>
      </CardContent>
    </Card>
  );
};
```

### 2. SEP Generation Interface
```typescript
// src/components/bpjs/SEPManagement/SEPForm.tsx
interface SEPFormProps {
  patient: BPJSPatient;
  onSEPGenerated: (sep: SEP) => void;
}

export const SEPForm: React.FC<SEPFormProps> = ({ patient, onSEPGenerated }) => {
  const { control, handleSubmit } = useForm<SEPFormData>();
  const generateSEP = useMutation(createSEP);

  return (
    <Card>
      <CardHeader 
        title="Generate SEP"
        subheader={`Patient: ${patient.name} (${patient.bpjsNumber})`}
      />
      <CardContent>
        <form onSubmit={handleSubmit(data => generateSEP.mutate(data))}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <Controller
                name="serviceType"
                control={control}
                render={({ field }) => (
                  <FormControl fullWidth>
                    <InputLabel>Service Type</InputLabel>
                    <Select {...field}>
                      <MenuItem value="1">Inpatient</MenuItem>
                      <MenuItem value="2">Outpatient</MenuItem>
                    </Select>
                  </FormControl>
                )}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <Controller
                name="clinicType"
                control={control}
                render={({ field }) => (
                  <Autocomplete
                    {...field}
                    options={clinicOptions}
                    renderInput={(params) => (
                      <TextField {...params} label="Clinic" />
                    )}
                  />
                )}
              />
            </Grid>
            {/* Add other form fields */}
          </Grid>
          <LoadingButton
            loading={generateSEP.isLoading}
            type="submit"
            variant="contained"
            color="primary"
            fullWidth
            sx={{ mt: 2 }}
          >
            Generate SEP
          </LoadingButton>
        </form>
      </CardContent>
    </Card>
  );
};
```

### 3. SEP Management Dashboard
```typescript
// src/pages/SEPManagement.tsx
export const SEPManagement: React.FC = () => {
  const { data: sepList, isLoading } = useQuery('seps', fetchSEPList);
  const [selectedSEP, setSelectedSEP] = useState<SEP | null>(null);

  return (
    <Container maxWidth="lg">
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Typography variant="h4" component="h1" gutterBottom>
            SEP Management
          </Typography>
        </Grid>
        
        <Grid item xs={12} md={8}>
          <Card>
            <CardHeader 
              title="Active SEPs"
              action={
                <Button
                  variant="contained"
                  startIcon={<AddIcon />}
                  onClick={() => setSelectedSEP(null)}
                >
                  New SEP
                </Button>
              }
            />
            <CardContent>
              {isLoading ? (
                <CircularProgress />
              ) : (
                <DataGrid
                  rows={sepList || []}
                  columns={SEP_COLUMNS}
                  pageSize={10}
                  autoHeight
                  onRowClick={({ row }) => setSelectedSEP(row)}
                />
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          {selectedSEP && (
            <SEPDetails
              sep={selectedSEP}
              onClose={() => setSelectedSEP(null)}
            />
          )}
        </Grid>
      </Grid>
    </Container>
  );
};
```

## UI/UX Improvements

1. **Modern Design Language**
   - Clean, minimalist interface
   - Consistent spacing and typography
   - Responsive design for all screen sizes
   - Dark mode support

2. **Enhanced User Experience**
   - Real-time form validation
   - Instant feedback on actions
   - Progressive loading for large datasets
   - Keyboard navigation support

3. **Performance Optimizations**
   - Code splitting and lazy loading
   - Optimistic UI updates
   - Efficient data caching
   - Minimal bundle size

4. **Accessibility**
   - WCAG 2.1 compliance
   - Screen reader support
   - Keyboard navigation
   - High contrast mode

## Implementation Steps

1. **Setup Development Environment**
   ```bash
   # Create new React project with Vite
   npm create vite@latest bpjs-sep-ui -- --template react-ts
   cd bpjs-sep-ui
   
   # Install dependencies
   npm install @mui/material @emotion/react @emotion/styled
   npm install @reduxjs/toolkit react-redux
   npm install react-query react-hook-form
   npm install @mui/x-data-grid @mui/lab
   ```

2. **Create Base Components**
   - Implement shared components
   - Set up theme and styling
   - Create layout components

3. **Implement Core Features**
   - BPJS verification
   - SEP generation
   - SEP management

4. **Integration and Testing**
   - Unit tests
   - Integration tests
   - End-to-end testing
   - Performance testing

## Security Considerations

1. **Authentication**
   - JWT-based authentication
   - Role-based access control
   - Session management

2. **Data Protection**
   - Input sanitization
   - XSS prevention
   - CSRF protection

3. **API Security**
   - Request signing
   - Rate limiting
   - Error handling

## Deployment Strategy

1. **Build Process**
   ```bash
   # Production build
   npm run build
   
   # Preview build
   npm run preview
   ```

2. **CI/CD Pipeline**
   - Automated testing
   - Code quality checks
   - Automated deployment

3. **Monitoring**
   - Error tracking
   - Performance monitoring
   - Usage analytics

## Migration Plan

1. **Phase 1: Development**
   - Set up new project
   - Implement core features
   - Internal testing

2. **Phase 2: Beta Testing**
   - Parallel running with existing system
   - User acceptance testing
   - Bug fixes and improvements

3. **Phase 3: Rollout**
   - Gradual user migration
   - Performance monitoring
   - Support and maintenance 